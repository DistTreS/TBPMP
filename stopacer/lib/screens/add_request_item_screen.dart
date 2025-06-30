import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/permintaan_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddRequestItemScreen extends StatefulWidget {
  const AddRequestItemScreen({super.key});

  @override
  State<AddRequestItemScreen> createState() => _AddRequestItemScreenState();
}

class _AddRequestItemScreenState extends State<AddRequestItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItemCode;
  int? _selectedVendorId;
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _vendors = [];
  bool _isLoading = false;
  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() => _isFetchingData = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final businessId = prefs.getInt('selected_business_id');

    if (token == null || businessId == null) {
      setState(() => _isFetchingData = false);
      return;
    }

    try {
      final itemRes = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/items/$businessId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final vendorRes = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/vendors/$businessId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (itemRes.statusCode == 200 && vendorRes.statusCode == 200) {
        final List<dynamic> itemsData = jsonDecode(itemRes.body);
        final List<dynamic> vendorsData = jsonDecode(vendorRes.body);

        setState(() {
          _items = itemsData.cast<Map<String, dynamic>>();
          _vendors = vendorsData.cast<Map<String, dynamic>>();
          _isFetchingData = false;
        });
      } else {
        setState(() => _isFetchingData = false);
        _showError('Gagal memuat data');
      }
    } catch (e) {
      setState(() => _isFetchingData = false);
      _showError('Error: $e');
      debugPrint('Error fetching dropdown data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await PermintaanService.addRequest(
        kodeBarang: _selectedItemCode!,
        idVendor: _selectedVendorId!,
        jumlah: int.parse(_jumlahController.text),
        catatan: _catatanController.text,
      );

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permintaan berhasil dibuat'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _showError(result['message'] ?? 'Gagal menambahkan permintaan');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Permintaan Barang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Form Permintaan Barang',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Dropdown for Items
                            DropdownButtonFormField<String>(
                              value: _selectedItemCode,
                              items: _items.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['kode_barang'],
                                  child: Text(
                                    item['nama_barang'],
                                    style: GoogleFonts.poppins(
                                      color: textColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedItemCode = value),
                              decoration: InputDecoration(
                                labelText: 'Pilih Barang',
                                labelStyle: GoogleFonts.poppins(
                                  color: textColor.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(Icons.inventory),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                              ),
                              dropdownColor: colorScheme.surface,
                              style: GoogleFonts.poppins(color: textColor),
                              validator: (value) =>
                                  value == null ? 'Pilih barang' : null,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Dropdown for Vendors
                            DropdownButtonFormField<int>(
                              value: _selectedVendorId,
                              items: _vendors.map((vendor) {
                                return DropdownMenuItem<int>(
                                  value: vendor['id_vendor'],
                                  child: Text(
                                    vendor['nama_vendor'],
                                    style: GoogleFonts.poppins(
                                      color: textColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedVendorId = value),
                              decoration: InputDecoration(
                                labelText: 'Pilih Vendor',
                                labelStyle: GoogleFonts.poppins(
                                  color: textColor.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                              ),
                              dropdownColor: colorScheme.surface,
                              style: GoogleFonts.poppins(color: textColor),
                              validator: (value) =>
                                  value == null ? 'Pilih vendor' : null,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Quantity Input
                            TextFormField(
                              controller: _jumlahController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Jumlah',
                                labelStyle: GoogleFonts.poppins(
                                  color: textColor.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Jumlah diperlukan'
                                  : int.tryParse(value) == null
                                  ? 'Harus berupa angka'
                                  : null,
                              style: GoogleFonts.poppins(color: textColor),
                            ),
                            const SizedBox(height: 16),
                            // Notes Input
                            TextFormField(
                              controller: _catatanController,
                              decoration: InputDecoration(
                                labelText: 'Catatan (Opsional)',
                                labelStyle: GoogleFonts.poppins(
                                  color: textColor.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(Icons.note),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                              ),
                              maxLines: 3,
                              style: GoogleFonts.poppins(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Kirim Permintaan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ).animate().scale(delay: 200.ms),
                  ],
                ),
              ),
            ),
    );
  }
}
