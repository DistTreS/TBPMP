import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AddStockOutScreen extends StatefulWidget {
  const AddStockOutScreen({super.key});

  @override
  State<AddStockOutScreen> createState() => _AddStockOutScreenState();
}

class _AddStockOutScreenState extends State<AddStockOutScreen> {
  final quantityController = TextEditingController();
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedKodeBarang;
  List<Map<String, dynamic>> barangList = [];

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  Future<void> _loadBarang() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idBisnis = prefs.getInt('selected_business_id');

    if (token == null || idBisnis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token atau ID bisnis tidak tersedia")),
      );
      return;
    }

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/items/$idBisnis"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        barangList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat daftar barang")),
      );
    }
  }

  Future<void> handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (selectedKodeBarang == null ||
        quantityController.text.isEmpty ||
        token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih barang dan isi jumlah terlebih dahulu."),
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("${Api.baseUrl}/stocks/out"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "kode_barang": selectedKodeBarang,
        "jumlah": int.tryParse(quantityController.text) ?? 0,
        "tanggal": selectedDate.toIso8601String(),
        "catatan": noteController.text,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok keluar berhasil ditambahkan!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            responseData['message'] ?? 'Gagal menambahkan stok keluar',
          ),
        ),
      );
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0x3350C2C9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Stok Keluar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      value: selectedKodeBarang,
                      decoration: buildInputDecoration("Pilih Barang"),
                      items: barangList.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['kode_barang'],
                          child: Text(item['nama_barang']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedKodeBarang = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration("Jumlah"),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: pickDate,
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: buildInputDecoration(
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: buildInputDecoration("Catatan"),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50C2C9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFD6F2F0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
