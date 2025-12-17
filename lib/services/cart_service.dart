import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop/models/product_model.dart';
import 'package:shop/services/auth_service.dart';

class CartServiceApi {
  static const String _baseUrl = 'http://localhost:3000';
  // Pour Android émulateur :
  // static const String _baseUrl = 'http://10.0.2.2:3000';

  static Future<List<ProductModel>> getCartProducts(String userId) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/cart/$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];
        return productsJson
            .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        print('Erreur serveur (getCart): ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur réseau (getCart): $e');
      return [];
    }
  }

  static Future<void> addToCart(String userId, String productId) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      await http.post(
        Uri.parse('$_baseUrl/cart/$userId/add'),
        headers: headers,
        body: json.encode({'productId': productId}),
      );
    } catch (e) {
      print('Erreur réseau (addToCart): $e');
    }
  }

  static Future<void> removeFromCart(String userId, String productId) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      await http.delete(
        Uri.parse('$_baseUrl/cart/$userId/remove/$productId'),
        headers: headers,
      );
    } catch (e) {
      print('Erreur réseau (removeFromCart): $e');
    }
  }

  static Future<void> clearCart(String userId) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      await http.delete(
        Uri.parse('$_baseUrl/cart/$userId/clear'),
        headers: headers,
      );
    } catch (e) {
      print('Erreur réseau (clearCart): $e');
    }
  }
}
