import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop/models/promotion_model.dart';

class PromotionService {
  // Pour Chrome / Web
  static const String _baseUrl = 'http://localhost:3000';
  // Pour Android émulateur :
  // static const String _baseUrl = 'http://10.0.2.2:3000';

  static Future<List<PromotionModel>> getActivePromotions() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/promotion/active'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => PromotionModel.fromJson(json))
            .toList();
      } else {
        print('Erreur serveur (promotions): ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur réseau (promotions): $e');
      return [];
    }
  }
}
