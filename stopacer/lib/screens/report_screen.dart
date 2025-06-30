import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/finance_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<Map<String, dynamic>> _summaryFuture;
  DateTimeRange? _selectedDateRange;
  String _selectedView = 'summary'; // 'summary' or 'detailed'

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<Map<String, dynamic>> _loadSummary() async {
    try {
      return await FinanceService.getSummary();
    } catch (e) {
      throw Exception("Failed to load financial data");
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ?? initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ), dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).colorScheme.background),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _selectedDateRange = pickedDateRange;
        _summaryFuture = _loadSummary();
      });
    }
  }

  String _formatDateRange() {
    if (_selectedDateRange == null) return "Last 30 Days";
    final format = DateFormat('MMM d, yyyy');
    return "${format.format(_selectedDateRange!.start)} - ${format.format(_selectedDateRange!.end)}";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Keuangan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Pilih Periode',
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'summary' ? 'detailed' : 'summary';
              });
            },
            tooltip: 'Ganti Tampilan',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ).animate().fadeIn();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat laporan",
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _summaryFuture = _loadSummary();
                      });
                    },
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            ).animate().shake();
          }

          final data = snapshot.data!;
          final income = double.tryParse(data['income'].toString()) ?? 0.0;
          final expense = double.tryParse(data['expense'].toString()) ?? 0.0;
          final balance = income - expense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Info
                Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_selectedView == 'summary') ...[
                  // Summary View
                  _buildSummaryCard(
                    context: context,
                    title: "Total Pemasukan",
                    amount: income,
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                    currencyFormat: currencyFormat,
                  ).animate().slideX(begin: -0.1, end: 0, duration: 300.ms),

                  const SizedBox(height: 16),

                  _buildSummaryCard(
                    context: context,
                    title: "Total Pengeluaran",
                    amount: expense,
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                    currencyFormat: currencyFormat,
                  ).animate().slideX(begin: 0.1, end: 0, duration: 300.ms, delay: 100.ms),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildSummaryCard(
                    context: context,
                    title: "Saldo Bersih",
                    amount: balance,
                    icon: Icons.account_balance_wallet,
                    color: balance >= 0 ? Colors.blue : Colors.orange,
                    currencyFormat: currencyFormat,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Mini Chart (Placeholder)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Grafik Keuangan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Visualisasi grafik akan ditampilkan di sini",
                              style: GoogleFonts.poppins(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ] else ...[
                  // Detailed View
                  _buildTransactionList(
                    context,
                    data['transactions'] ?? [],
                    currencyFormat,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required NumberFormat currencyFormat,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = amount >= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(amount),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              backgroundColor: color.withOpacity(0.1),
              label: Text(
                isPositive ? 'Positif' : 'Negatif',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<dynamic> transactions,
    NumberFormat currencyFormat,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Tidak ada transaksi pada periode ini",
              style: GoogleFonts.poppins(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detail Transaksi",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...transactions.map((tx) {
          final isIncome = tx['type'] == 'income';
          final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
          final date = DateTime.parse(tx['date']);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isIncome
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                tx['description'] ?? 'Transaksi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy HH:mm').format(date),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              trailing: Text(
                "${isIncome ? '+' : '-'} ${currencyFormat.format(amount)}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ),
          ).animate().slideX(
            begin: 0.1,
            end: 0,
            duration: 300.ms,
          );
        }),
      ],
    );
  }
}