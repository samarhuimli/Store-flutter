// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/models/product_model.dart';
import 'package:shop/models/review_model.dart';

class ProductService {
  // Pour Chrome / Web
  static const String _baseUrl = 'http://localhost:3000';

  // Pour Android émulateur → décommente la ligne ci-dessous et commente celle du haut
  // static const String _baseUrl = 'http://10.0.2.2:3000';

  static Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        print("Erreur serveur: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur réseau: $e");
      return [];
    }
  }

  static Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else {
        print("Erreur serveur (getProductById): ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur réseau (getProductById): $e");
      return null;
    }
  }

  static Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/products/by-category/$categoryId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        print("Erreur serveur (catégorie): ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur réseau (catégorie): $e");
      return [];
    }
  }

  static Future<List<ProductReview>> getReviews(String productId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/products/$productId/reviews'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data
            .map((json) => ProductReview.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print("Erreur serveur (getReviews): ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur réseau (getReviews): $e");
      return [];
    }
  }

  static Future<bool> addReview({
    required String productId,
    required double rating,
    required String comment,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products/$productId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userName': userName,
          'rating': rating,
          'comment': comment,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Erreur réseau (addReview): $e");
      return false;
    }
  }
}