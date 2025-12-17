// lib/screens/home/views/components/popular_products.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/services/product_service.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Produits populaires",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        FutureBuilder<List<ProductModel>>(
          future: ProductService.getProducts(), // ← les vrais produits
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucun produit"));
            }

            final products = snapshot.data!;
            return SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      title: p.name,
                      image: p.images.isNotEmpty
                          ? p.images[0]
                          : "https://via.placeholder.com/150",
                      brandName: p.brand ?? "Marque",
                      price: p.price,
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false)
                              .addToCart(p);
                        },
                      ),
                      press: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(p.name)),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}