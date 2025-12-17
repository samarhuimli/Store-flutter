import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/Banner/M/banner_m_with_counter.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/promotion_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/services/promotion_service.dart';
import 'package:shop/route/route_constants.dart';
import '../../../../constants.dart';

class FlashSale extends StatefulWidget {
  const FlashSale({super.key});

  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
  late Future<List<PromotionModel>> promotions;

  @override
  void initState() {
    super.initState();
    promotions = PromotionService.getActivePromotions();
  }

  Duration _computeRemainingDuration(List<PromotionModel> promos) {
    if (promos.isEmpty) {
      return const Duration(seconds: 0);
    }

    final now = DateTime.now();

    // On prend la promotion qui se termine le plus tôt
    DateTime? earliestEnd;
    for (final promo in promos) {
      final end = promo.endDate;
      if (end.isBefore(now)) {
        continue;
      }

      if (earliestEnd == null || end.isBefore(earliestEnd)) {
        earliestEnd = end;
      }
    }

    if (earliestEnd == null) {
      return const Duration(seconds: 0);
    }

    final diff = earliestEnd.difference(now);
    if (diff.isNegative) {
      return const Duration(seconds: 0);
    }

    return diff;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PromotionModel>>(
      future: promotions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        final remaining = _computeRemainingDuration(items);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BannerMWithCounter(
              image: 'assets/images/promotion.jpg',
              duration: remaining,
              text: "Super Flash Sale \n50% Off",
              press: () {},
            ),
            const SizedBox(height: defaultPadding / 2),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                "Flash sale",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final promo = items[index];
                  final p = promo.product;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right: index == items.length - 1 ? defaultPadding : 0,
                    ),
                    child: ProductCard(
                      image: p.firstImage,
                      brandName: p.brand ?? "Unknown",
                      title: p.name,
                      price: p.price,
                      priceAfetDiscount: promo.discountedPrice,
                      dicountpercent: promo.discountPercent,
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
              ),
            ),
          ],
        );
      },
    );
  }
}
