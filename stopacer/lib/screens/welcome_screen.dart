import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF50C2C9);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -10,
            left: -120,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0x3350C2C9), 
                shape: BoxShape.circle,
              ),
            ),
          ),

          
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                color: Color(0x3350C2C9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "Stopacer",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/gambar1.jpg',
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Stock & Expense Tracker\naplikasi sederhana namun powerful yang membantu UMKM dan individu dalam mengelola stok barang serta mencatat pemasukan dan pengeluaran dengan mudah.\n\nKelola stok, kendalikan pengeluaran, dan maksimalkan keuntungan dalam satu aplikasi!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pantau Stok, Kendalikan Pengeluaran!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text("Mari mulai"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
