// lib/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final List<String> images;
  final int stock;
  final double rating;
  final int reviewsCount;
  final String? brand;
  final bool isActive;
  final String? categoryId;
  final String? categoryName;

  final double? discountedPrice;
  final int? discountPercent;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.images = const [],
    this.stock = 0,
    this.rating = 0,
    this.reviewsCount = 0,
    this.brand,
    this.isActive = true,
    this.categoryId,
    this.categoryName,
    this.discountedPrice,
    this.discountPercent,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawCategory = json['category'];

    String? resolvedCategoryId;
    String? resolvedCategoryName;

    if (rawCategory is Map<String, dynamic>) {
      resolvedCategoryId = rawCategory['_id']?.toString();
      resolvedCategoryName = rawCategory['name']?.toString();
    } else if (rawCategory != null) {
      resolvedCategoryId = rawCategory.toString();
    }

    final dynamic rawPrice = json['price'];
    final dynamic rawRating = json['rating'];
    final dynamic rawDiscountedPrice = json['discountedPrice'];

    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: rawPrice is int
          ? rawPrice.toDouble()
          : (rawPrice is num ? rawPrice.toDouble() : 0.0),
      description: json['description']?.toString(),
      images: (json['images'] is List)
          ? List<String>.from((json['images'] as List).map((e) => e.toString()))
          : <String>[],
      stock: (json['stock'] is int) ? json['stock'] as int : 0,
      rating: rawRating is int
          ? rawRating.toDouble()
          : (rawRating is num ? rawRating.toDouble() : 0.0),
      reviewsCount: (json['reviewsCount'] is int) ? json['reviewsCount'] as int : 0,
      brand: json['brand']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      categoryId: resolvedCategoryId,
      categoryName: resolvedCategoryName,
      discountedPrice: rawDiscountedPrice is num
          ? rawDiscountedPrice.toDouble()
          : null,
      discountPercent: json['discountPercent'] is int
          ? json['discountPercent'] as int
          : null,
    );
  }
}

// Extension pour récupérer une image par défaut
extension ProductExtensions on ProductModel {
  /// Retourne la première image ou une image par défaut
String get firstImage => images.isNotEmpty ? images.first : "https://via.placeholder.com/150";
}


