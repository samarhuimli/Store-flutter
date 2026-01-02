import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shop/components/buy_full_ui_kit.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/review_model.dart';
import 'package:shop/services/product_service.dart';

import 'package:shop/route/screen_export.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final reviewsFuture = ProductService.getReviews(product.id);
    return Scaffold(
      bottomNavigationBar: product.stock > 0
          ? CartButton(
              price: product.discountedPrice ?? product.price,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: product),
                );
              },
            )
          :

          /// If profuct is not available then show [NotifyMeCard]
          NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            ProductImages(
              images:
                  product.images.isNotEmpty ? product.images : [product.firstImage],
            ),
            ProductInfo(
              brand: product.brand ?? "Unknown",
              title: product.name,
              isAvailable: product.stock > 0,
              description: product.description ?? "",
              rating: product.rating,
              numOfReviews: product.reviewsCount,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Product Details",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const BuyFullKit(
                      images: ["assets/screens/Product detail.png"]),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: product.rating,
                  numOfReviews: product.reviewsCount,
                  numOfFiveStar: product.reviewsCount,
                  numOfFourStar: 0,
                  numOfThreeStar: 0,
                  numOfTwoStar: 0,
                  numOfOneStar: 0,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<ProductReview>>(
                future: reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final lastTwo = reviews.length <= 2
                      ? reviews.reversed.toList()
                      : reviews.reversed.take(2).toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Derniers avis',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        ...lastTwo.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: defaultPadding / 2),
                            child: _MiniReviewTile(review: r),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(
                  context,
                  productReviewsScreenRoute,
                  arguments: product,
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: FutureBuilder<List<ProductModel>>(
                  future: product.categoryId != null
                      ? ProductService.getProductsByCategory(
                          product.categoryId!,
                        )
                      : ProductService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final recommendations = snapshot.data!
                        .where((p) => p.id != product.id)
                        .toList();

                    if (recommendations.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final p = recommendations[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: defaultPadding,
                            right: index == recommendations.length - 1
                                ? defaultPadding
                                : 0,
                          ),
                          child: ProductCard(
                            image: p.firstImage,
                            title: p.name,
                            brandName: p.brand ?? "Unknown",
                            price: p.price,
                            priceAfetDiscount: p.discountedPrice ?? p.price,
                            dicountpercent: p.discountPercent ?? 0,
                            press: () {
                              Navigator.pushNamed(
                                context,
                                productDetailsScreenRoute,
                                arguments: p,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}

class _MiniReviewTile extends StatelessWidget {
  const _MiniReviewTile({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(child: Text(review.userName)),
          RatingBarIndicator(
            rating: review.rating,
            itemSize: 16,
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
          if ((review.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.comment!),
          ],
          const SizedBox(height: 2),
          Text(
            review.createdAt.toLocal().toString().split(' ').first,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
