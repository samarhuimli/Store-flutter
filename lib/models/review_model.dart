class ProductReview {
  final String userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ProductReview({
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    return ProductReview(
      userName: (json['userName'] ?? '').toString(),
      rating: rawRating is int
          ? rawRating.toDouble()
          : (rawRating is num ? rawRating.toDouble() : 0.0),
      comment: json['comment']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
