import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class BusinessService {
  static Future<List<Map<String, dynamic>>> getUserBusinesses(
    int userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/business/user/$userId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Gagal mengambil bisnis');
    }
  }

static Future<Map<String, dynamic>> createBusiness({
  required int userId,
  required String nama,
  String? deskripsi,
  String? logo,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  final response = await http.post(
    Uri.parse("${Api.baseUrl}/business"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'user_id': userId,
      'nama': nama,
      'logo': logo ?? '',
      'deskripsi': deskripsi ?? '',
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 201 && data['business'] != null) {
    return {
      'success': true,
      'business': data['business'],
    };
  } else {
    return {
      'success': false,
      'message': data['message'] ?? 'Gagal membuat bisnis',
    };
  }
}

  /// Simpan bisnis yang dipilih
  static Future<void> setSelectedBusiness(int id, String nama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_business_id', id);
    await prefs.setString('selected_business_name', nama);
  }

  /// Ambil bisnis yang sedang dipilih
  static Future<String?> getSelectedBusinessName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_business_name');
  }
}
