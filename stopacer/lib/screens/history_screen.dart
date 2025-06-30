import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/finance_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;
  List<Map<String, dynamic>> _allTransactions = [];
  String _selectedFilter = 'all';
  bool _isLoading = false;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _loadTransactions();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      _allTransactions = await FinanceService.getTransactionHistory();
      return _allTransactions;
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      throw Exception("Failed to load transactions");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {});
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
    );

    if (pickedDateRange != null) {
      setState(() {
        _selectedDateRange = pickedDateRange;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _transactionsFuture = _loadTransactions();
    });
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> filtered = _allTransactions;

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered = filtered.where((t) => t['type'] == _selectedFilter).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) {
        final date = t['date'];
        return date.isAfter(_selectedDateRange!.start) &&
            date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        final description = t['description']?.toString().toLowerCase() ?? '';
        final note = t['catatan']?.toString().toLowerCase() ?? '';
        return description.contains(query) || note.contains(query);
      }).toList();
    }

    return filtered;
  }

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);
  String _formatAmount(double amount) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);

  String _formatDateRange() {
    if (_selectedDateRange == null) return "30 Hari Terakhir";
    return "${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filter Tanggal',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            ).animate().fadeIn();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat data transaksi",
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _refreshData,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            ).animate().shake();
          }

          _allTransactions = snapshot.data!;
          final transactions = _filteredTransactions;

          return Column(
            children: [
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withOpacity(
                                0.3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDateRange(),
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.filter_alt),
                          onSelected: (value) {
                            setState(() => _selectedFilter = value);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'all',
                              child: Text('Semua Transaksi'),
                            ),
                            const PopupMenuItem(
                              value: 'income',
                              child: Text('Pemasukan'),
                            ),
                            const PopupMenuItem(
                              value: 'expense',
                              child: Text('Pengeluaran'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Active Filters
              if (_selectedFilter != 'all' || _searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedFilter != 'all')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(
                                _selectedFilter == 'income'
                                    ? 'Pemasukan'
                                    : 'Pengeluaran',
                              ),
                              onDeleted: () {
                                setState(() => _selectedFilter = 'all');
                              },
                            ),
                          ),
                        if (_searchController.text.isNotEmpty)
                          Chip(
                            label: Text('Pencarian: ${_searchController.text}'),
                            onDeleted: () {
                              _searchController.clear();
                            },
                          ),
                      ],
                    ),
                  ),
                ),

              // Transaction List
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Tidak ada transaksi pada periode ini'
                                  : 'Transaksi tidak ditemukan',
                              style: GoogleFonts.poppins(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty ||
                                _selectedFilter != 'all')
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedFilter = 'all';
                                  });
                                },
                                child: const Text('Reset Filter'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final item = transactions[index];
                            final isIncome = item['type'] == 'income';
                            final date = item['date'];
                            final amount = item['amount'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showDetails(context, item),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isIncome
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          isIncome
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isIncome
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['description'] ??
                                                  'Transaksi',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_formatDate(date)} • ${_formatTime(date)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            (isIncome ? '+ ' : '- ') +
                                                _formatAmount(amount),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: isIncome
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          if (item['catatan'] != null)
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                item['catatan'],
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.end,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().slideX(
                              begin: index.isOdd ? 0.1 : -0.1,
                              end: 0,
                              duration: 300.ms,
                              delay: (index * 50).ms,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> item) {
    final isIncome = item['type'] == 'income';
    final date = item['date'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isIncome ? 'Detail Pemasukan' : 'Detail Pengeluaran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Deskripsi", item['description'] ?? '-'),
            _buildDetailRow(
              "Tanggal",
              '${_formatDate(date)} ${_formatTime(date)}',
            ),
            _buildDetailRow(
              "Jumlah",
              (isIncome ? '+ ' : '- ') + _formatAmount(item['amount']),
              isAmount: true,
              isIncome: isIncome,
            ),
            _buildDetailRow("Kategori", item['kategori'] ?? '-'),
            _buildDetailRow("Catatan", item['catatan'] ?? '-'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isAmount = false,
    bool isIncome = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[600])),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: isAmount ? FontWeight.w600 : FontWeight.w500,
              color: isAmount
                  ? isIncome
                        ? Colors.green
                        : Colors.red
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
