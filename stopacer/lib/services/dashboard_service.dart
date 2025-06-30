import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getSummaryToday() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final businessId = prefs.getInt('selected_business_id');

    if (token == null || businessId == null) {
      throw Exception("Token atau ID bisnis tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse('${Api.baseUrl}/transactions/summary/$businessId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data ringkasan");
    }
  }
}
