import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class UserService {
  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/users/me"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': 'Gagal memuat data'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

    final body = {
      'name': name,
      'email': email,
    };
    if (password != null) body['password'] = password;

    final response = await http.put(
      Uri.parse("${Api.baseUrl}/users/me"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? '',
    };
  }
}
