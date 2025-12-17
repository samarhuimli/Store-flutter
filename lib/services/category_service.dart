import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/models/category_model.dart';

class CategoryService {
  static const String _baseUrl = 'http://localhost:3000/categories';

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du fetch des catégories');
    }
  }

  static Future<void> addCategory(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteCategory(String id) async {
    await http.delete(Uri.parse('$_baseUrl/$id'));
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    return fetchCategories();
  }

  static Future<List<CategoryModel>> getCategoryModels() async {
    final raw = await fetchCategories();
    return raw.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
