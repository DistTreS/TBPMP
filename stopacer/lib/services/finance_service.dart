import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class FinanceService {
  static Future<Map<String, dynamic>> addTransaction({
    required String tipe,
    required double jumlah,
    required String deskripsi,
    required DateTime tanggal,
    String? catatan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      return {'success': false, 'message': 'Token atau bisnis tidak ditemukan'};
    }

    final response = await http.post(
      Uri.parse("${Api.baseUrl}/finances"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_bisnis': idBisnis,
        'tipe': tipe,
        'jumlah': jumlah,
        'deskripsi': deskripsi,
        'tanggal': tanggal.toIso8601String(),
        'catatan': catatan ?? '',
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menyimpan transaksi',
      };
    }
  }

  static Future<Map<String, dynamic>> getSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      throw Exception("Token atau ID bisnis tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/finances/summary/$idBisnis"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil ringkasan keuangan");
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      throw Exception("Token atau ID bisnis tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/finances/history/$idBisnis"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return {
          'id': item['id'],
          'type': item['type'], // 'income' atau 'expense'
          'amount': (item['amount'] as num).toDouble(),
          'description': item['description'],
          'catatan': item['catatan'] ?? '--',
          'date': DateTime.parse(item['date']),
        };
      }).toList();
    } else {
      throw Exception("Gagal mengambil riwayat transaksi");
    }
  }
}
