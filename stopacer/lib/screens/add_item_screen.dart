import 'package:flutter/material.dart';
import '../services/item_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final initialStockController = TextEditingController();
  final priceController = TextEditingController();

  bool _isLoading = false;

  void handleSubmit() async {
    final kode = codeController.text.trim();
    final nama = nameController.text.trim();
    final stok = int.tryParse(initialStockController.text.trim()) ?? 0;
    final harga = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (kode.isEmpty || nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode dan nama barang wajib diisi.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ItemService.createItem(
      kodeBarang: kode,
      namaBarang: nama,
      jumlahStok: stok,
      harga: harga,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barang berhasil ditambahkan!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menambahkan barang'),
        ),
      );
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
                      "Tambah barang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Optional Logo
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F2F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo_outlined, size: 36),
                        onPressed: () {
                          // TODO: Implement logo picker if needed
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: codeController,
                      decoration: buildInputDecoration("Kode Barang"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nameController,
                      decoration: buildInputDecoration("Nama Barang"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: initialStockController,
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration("Jumlah Awal"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration("Harga (Rp)"),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50C2C9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isLoading ? null : handleSubmit,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
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
