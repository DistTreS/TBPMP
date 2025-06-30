import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/item_service.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Map<String, dynamic>>> _loadItems() async {
    try {
      final items = await ItemService.getAllItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
      });
      return items;
    } catch (e) {
      setState(() {
        _allItems = [];
        _filteredItems = [];
      });
      rethrow;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredItems = _allItems.where((item) {
        final name = item['nama_barang'].toString().toLowerCase();
        final code = item['kode_barang'].toString().toLowerCase();
        final category = item['kategori']?.toString().toLowerCase() ?? '';

        // Advanced search - checks multiple fields
        return name.contains(query) ||
            code.contains(query) ||
            category.contains(query);
      }).toList();
    });
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = _loadItems();
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });
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
          "Daftar Barang",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Future.delayed(100.ms, () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  showSearch(
                    context: context,
                    delegate: ItemSearchDelegate(_allItems),
                  );
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              ).animate().fadeIn();
            }

            if (snapshot.hasError) {
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
                      "Gagal memuat data barang",
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _refreshItems,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ).animate().shake();
            }

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari barang...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),

                // Item List
                Expanded(
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isSearching
                                    ? "Tidak ditemukan barang yang cocok"
                                    : "Belum ada barang tersedia",
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              if (_isSearching)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: const Text("Reset pencarian"),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final stock = item['jumlah_stok'] as int;
                            final isLowStock =
                                stock <= (item['stok_minimal'] ?? 5);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/item-detail',
                                    arguments: item,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Item Icon
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.inventory_2,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Item Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['nama_barang'],
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Kode: ${item['kode_barang']}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Stock Info
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "$stock ${item['satuan'] ?? 'pcs'}",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: isLowStock
                                                  ? Colors.red
                                                  : colorScheme.primary,
                                            ),
                                          ),
                                          if (isLowStock)
                                            Text(
                                              "Stok Rendah",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.red,
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
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-stock-in');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add),
      ).animate().scale(delay: 300.ms),
    );
  }
}

class ItemSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> items;

  ItemSearchDelegate(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = items.where((item) {
      final name = item['nama_barang'].toString().toLowerCase();
      final code = item['kode_barang'].toString().toLowerCase();
      final category = item['kategori']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          code.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item['nama_barang']),
          subtitle: Text("Kode: ${item['kode_barang']}"),
          trailing: Text("Stok: ${item['jumlah_stok']}"),
          onTap: () {
            close(context, null);
            Navigator.pushNamed(context, '/item-detail', arguments: item);
          },
        );
      },
    );
  }
}
