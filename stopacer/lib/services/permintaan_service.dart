import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class PermintaanService {
  // Ambil daftar permintaan barang berdasarkan id_bisnis
  static Future<Map<String, dynamic>> fetchRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      return {'success': false, 'message': 'Data tidak lengkap'};
    }

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/permintaan/$idBisnis"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  // Tambah permintaan barang baru
  static Future<Map<String, dynamic>> addRequest({
    required String kodeBarang,
    required int idVendor,
    required int jumlah,
    required String catatan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      return {'success': false, 'message': 'Data tidak lengkap'};
    }

    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/permintaan"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_bisnis': idBisnis,
          'kode_barang': kodeBarang,
          'id_vendor': idVendor,
          'jumlah': jumlah,
          'catatan': catatan,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan permintaan',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }
}
