import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/services/product_service.dart';
import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class MostPopular extends StatefulWidget {
  const MostPopular({super.key});

  @override
  State<MostPopular> createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
  late Future<List<ProductModel>> products;

  @override
  void initState() {
    super.initState();
    products = ProductService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Most popular",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 114,
          child: FutureBuilder<List<ProductModel>>(
            future: products,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final p = items[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right: index == items.length - 1 ? defaultPadding : 0,
                    ),
                    child: SecondaryProductCard(
                      image: p.firstImage,
                      brandName: p.brand ?? "Unknown",
                      title: p.name,
                      price: p.price,
                      priceAfetDiscount: p.discountedPrice ?? p.price,
                      dicountpercent: p.discountPercent ?? 0,
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
