import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/route/route_constants.dart';
import '../../../constants.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: ProductService.getProductsByCategory(category.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit dans cette catégorie'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: defaultPadding,
              crossAxisSpacing: defaultPadding,
              childAspectRatio: 0.66,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];

              return ProductCard(
                image: p.firstImage,
                brandName: p.brand ?? 'Unknown',
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
              );
            },
          );
        },
      ),
    );
  }
}
