import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _summaryFuture;
  String? _userName;
  String? _businessName;

  @override
  void initState() {
    super.initState();
    _loadUserAndBusiness();
    _summaryFuture = DashboardService.getSummaryToday();
  }

  Future<void> _loadUserAndBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final businessName = prefs.getString('selected_business_name');

    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          setState(() {
            _userName = payload['name'] ?? 'User';
          });
        }
      } catch (_) {}
    }

    setState(() {
      _businessName = businessName ?? 'Bisnis Anda';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan user dan bisnis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${_userName ?? '...'}!",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            _businessName ?? 'Bisnis Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Ringkasan Hari Ini
                  FutureBuilder<Map<String, dynamic>>(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Text("Gagal memuat data");
                      }

                      final data = snapshot.data!;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withOpacity(0.9),
                              colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Summary",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatItem(
                                  icon: Icons.arrow_downward,
                                  label: "Stock In",
                                  value: "${data['stockIn']}",
                                  color: Colors.white,
                                ),
                                _StatItem(
                                  icon: Icons.arrow_upward,
                                  label: "Stock Out",
                                  value: "${data['stockOut']}",
                                  color: Colors.white,
                                ),
                                _StatItem(
                                  icon: Icons.attach_money,
                                  label: "Income",
                                  value: "${data['income']}",
                                  color: Colors.white,
                                ),
                                _StatItem(
                                  icon: Icons.money_off,
                                  label: "Expense",
                                  value: "${data['expense']}",
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().slideX(begin: -0.1, end: 0, duration: 500.ms);
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Quick Actions",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 16),

                  // Menu Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                      children: [
                        _DashboardMenuItem(
                          icon: Icons.inventory_2,
                          title: "Stock In",
                          route: '/add-stock-in',
                          color: Colors.blueAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.inventory_outlined,
                          title: "Stock Out",
                          route: '/add-stock-out',
                          color: Colors.redAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.attach_money,
                          title: "Income",
                          route: '/add-income',
                          color: Colors.greenAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.money_off,
                          title: "Expense",
                          route: '/add-expense',
                          color: Colors.orangeAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.list_alt,
                          title: "Stock Report",
                          route: '/stock-list',
                          color: Colors.purpleAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.bar_chart,
                          title: "Finance Report",
                          route: '/report',
                          color: Colors.tealAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.local_shipping,
                          title: "Vendors",
                          route: '/vendors',
                          color: Colors.indigoAccent,
                        ),
                        _DashboardMenuItem(
                          icon: Icons.request_page,
                          title: "Requests",
                          route: '/request-list',
                          color: Colors.pinkAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, colorScheme),
    );
  }

  BottomNavigationBar _buildBottomNavBar(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
      ],
      onTap: (index) {
        if (index == 1) Navigator.pushNamed(context, '/history');
        if (index == 2) Navigator.pushNamed(context, '/account');
      },
    );
  }
}

class _DashboardMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final Color color;

  const _DashboardMenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
