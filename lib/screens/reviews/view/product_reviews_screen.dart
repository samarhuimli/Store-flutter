import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/review_model.dart';
import 'package:shop/screens/reviews/view/components/review_product_card.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/services/auth_service.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  late Future<List<ProductReview>> _reviewsFuture;
  double _newRating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ProductService.getReviews(widget.product.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _reloadReviews() async {
    setState(() {
      _reviewsFuture = ProductService.getReviews(widget.product.id);
    });
  }

  Future<void> _submitReview() async {
    if (_submitting) return;
    final comment = _commentController.text.trim();
    if (_newRating <= 0) return;

    setState(() {
      _submitting = true;
    });

    // On récupère le username de l'utilisateur connecté (fallback "Client" si absent).
    final userName = await AuthService.getUsername() ?? 'Client';

    final success = await ProductService.addReview(
      productId: widget.product.id,
      rating: _newRating,
      comment: comment,
      userName: userName,
    );

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    if (success) {
      _commentController.clear();
      await _reloadReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre avis !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'envoyer votre avis.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewProductInfoCard(
              image: widget.product.firstImage,
              title: widget.product.name,
              brand: widget.product.brand ?? 'Unknown',
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: FutureBuilder<List<ProductReview>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(
                      child: Text('Aucun avis pour le moment. Soyez le premier !'),
                    );
                  }

                  return ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final r = reviews[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(r.userName)),
                            RatingBarIndicator(
                              rating: r.rating,
                              itemSize: 18,
                              unratedColor: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(0.1),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((r.comment ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(r.comment!),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              r.createdAt.toLocal().toString().split(' ').first,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Donnez votre avis',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: defaultPadding / 2),
            RatingBar.builder(
              initialRating: _newRating,
              minRating: 1,
              itemSize: 28,
              allowHalfRating: true,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                setState(() {
                  _newRating = value;
                });
              },
            ),
            const SizedBox(height: defaultPadding / 2),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Écrivez votre commentaire...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitReview,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Envoyer mon avis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
