import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class ItemService {
  static Future<Map<String, dynamic>> createItem({
    required String kodeBarang,
    required String namaBarang,
    required int jumlahStok,
    required double harga,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      return {
        'success': false,
        'message': 'Token atau ID bisnis tidak tersedia',
      };
    }

    final response = await http.post(
      Uri.parse("${Api.baseUrl}/items"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_bisnis': idBisnis,
        'kode_barang': kodeBarang,
        'nama_barang': namaBarang,
        'jumlah_stok': jumlahStok,
        'harga': harga,
        'ambang_batas_barang': 0,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menambahkan barang',
      };
    }
  }

  // 👇 Tambahan: Ambil semua barang
  static Future<List<Map<String, dynamic>>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      throw Exception("Token atau ID bisnis tidak tersedia");
    }

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/items/$idBisnis"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Gagal mengambil daftar barang");
    }
  }

  static Future<List<Map<String, dynamic>>> getItemHistory(
    String kodeBarang,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/stocks/history/$kodeBarang"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Gagal mengambil riwayat barang');
    }
  }

  static Future<bool> updateItemField({
    required String kodeBarang,
    required String field,
    required dynamic value,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse("${Api.baseUrl}/items/update-field"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'kode_barang': kodeBarang,
        'field': field,
        'value': value,
      }),
    );

    return response.statusCode == 200;
  }
}
