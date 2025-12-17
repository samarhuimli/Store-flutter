import 'package:shop/models/product_model.dart';

class PromotionModel {
  final String id;
  final ProductModel product;
  final int discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  PromotionModel({
    required this.id,
    required this.product,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  double get discountedPrice {
    final price = product.price;
    return price - (price * discountPercentage / 100);
  }

  int get discountPercent => discountPercentage;

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>;

    return PromotionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: ProductModel.fromJson(productJson),
      discountPercentage: json['discountPercentage'] is int
          ? json['discountPercentage'] as int
          : int.tryParse(json['discountPercentage'].toString()) ?? 0,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }
}
