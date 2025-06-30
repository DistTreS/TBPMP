import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class VendorService {
  // Ambil daftar vendor untuk bisnis yang sedang dipilih
  static Future<Map<String, dynamic>> fetchVendors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      return {
        'success': false,
        'message': 'Token atau ID bisnis tidak ditemukan',
      };
    }

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/vendors/$idBisnis"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      print('🔍 Fetch Vendors Status: ${response.statusCode}');
      print('📦 Response: $data');

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil vendor',
        };
      }
    } catch (e) {
      print('❌ Exception fetchVendors: $e');
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  // Tambah vendor baru
  static Future<Map<String, dynamic>> addVendor({
    required String name,
    required String contact,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');
    

    if (token == null || idBisnis == null) {
      return {'success': false, 'message': 'Data tidak lengkap'};
    }

    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/vendors"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_bisnis': idBisnis,
          'nama_vendor': name,
          'kontak': contact,
          'alamat': address,
        }),
      );

      final data = jsonDecode(response.body);
      print('📤 Add Vendor Status: ${response.statusCode}');
      print('📦 Response: $data');

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan vendor',
        };
      }
    } catch (e) {
      print('❌ Exception addVendor: $e');
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }
}
