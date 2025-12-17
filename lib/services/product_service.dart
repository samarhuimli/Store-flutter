// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/models/product_model.dart';

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
}