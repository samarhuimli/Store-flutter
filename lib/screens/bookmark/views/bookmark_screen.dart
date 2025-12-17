import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/route/route_constants.dart';
import '../../../constants.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<List<ProductModel>> products;

  @override
  void initState() {
    super.initState();
    products = ProductService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            sliver: FutureBuilder<List<ProductModel>>(
              future: products,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final items = snapshot.data!;

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final p = items[index];

                      return ProductCard(
                        image: p.firstImage,
                        brandName: p.brand ?? "Unknown",
                        title: p.name,
                        price: p.price,
                        priceAfetDiscount: p.discountedPrice ?? p.price,
                        dicountpercent: p.discountPercent ?? 0,
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.add_shopping_cart, size: 18),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(p);
                          },
                        ),
                        press: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: p,
                          );
                        },
                      );
                    },
                    childCount: items.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
