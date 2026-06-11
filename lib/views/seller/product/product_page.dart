// ============================================================
// SELLER PRODUCT PAGE 
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart';
import 'package:byteme_digital_marketplace/views/seller/home/home_page.dart';
import 'package:byteme_digital_marketplace/views/seller/product/add_product.dart';
import 'package:byteme_digital_marketplace/views/seller/product/edit_product.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class SellerProductPage extends StatefulWidget {
  const SellerProductPage({super.key, required void Function() onBackPressed});

  @override
  State<SellerProductPage> createState() => _SellerProductPageState();
}

class _SellerProductPageState extends State<SellerProductPage> {
  // ── WARNA UTAMA ──
  static const Color _accentColor = Color(0xFF3D4270);
  static const Color _primaryBlue = Color(0xFF6B7FD7);
  static const Color _bgColor = Color(0xFFF0F2F8);

  // ── SEARCH & LOCAL DATA STATE ──
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _localProducts = [];
  bool _isLocalLoading = true;

  // ── FILTER STATE ──
  String? _selectedFilter; // null = Semua, 'approved', 'pending', 'rejected'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    
    _fetchProductsFromLocalBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengambil data langsung dari backend lokal
  Future<void> _fetchProductsFromLocalBackend() async {
    if (!mounted) return;
    setState(() => _isLocalLoading = true);
    try {
      final res = await ApiService.get('/my-produk');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List raw = decoded is List ? decoded : (decoded['data'] ?? []);
        if (mounted) {
          setState(() {
            _localProducts = raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
            _isLocalLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLocalLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLocalLoading = false);
    }
  }

  // Menerjemahkan status mentah menjadi status efektif untuk filter
  String _getEffectiveStatus(String? rawStatus) {
    final status = (rawStatus ?? '').toString().toLowerCase();
    if (status == 'approved' || status == 'active') {
      return 'approved';
    } else if (status == 'pending') {
      return 'pending';
    } else if (status == 'rejected' || status == 'ditolak') {
      return 'rejected';
    }
    return 'draft';
  }

  // Menghitung jumlah produk per status untuk badge filter
  int _countByStatus(String? filterValue) {
    if (filterValue == null) return _localProducts.length;
    return _localProducts.where((p) {
      return _getEffectiveStatus(p['status']) == filterValue;
    }).length;
  }

  // HELPER FORMAT RUPIAH
  String _formatRupiah(dynamic rawAmount) {
    if (rawAmount == null) return 'Rp 0';
    if (rawAmount.toString().startsWith('Rp')) return rawAmount.toString();
    
    double amount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse(rawAmount.toString()) ?? 0.0);
    if (amount == 0) return 'Rp 0';
    
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  // HELPER STATUS BADGE 
  Color _statusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF0F2F8);
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Draft';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        final query = _searchController.text.toLowerCase();
        
        // 🌟 Filter gabungan (Search + Status Tab)
        final filteredProducts = _localProducts.where((p) {
          final title = (p['nama_produk'] ?? p['title'] ?? '').toString().toLowerCase();
          final matchesSearch = title.contains(query);
          
          final effectiveStatus = _getEffectiveStatus(p['status']);
          final matchesStatus = _selectedFilter == null || effectiveStatus == _selectedFilter;

          return matchesSearch && matchesStatus;
        }).toList();

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(filteredProducts.length),
                _buildSearchBar(),
                
                // ── FILTER TABS ──
                if (!_isLocalLoading && _localProducts.isNotEmpty) _buildFilterTabs(),

                // ── LIST PRODUK ──
                Expanded(
                  child: _isLocalLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF6B7FD7)),
                        )
                      : filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _fetchProductsFromLocalBackend,
                              color: _primaryBlue,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(
                                    filteredProducts[index],
                                    productController,
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              ).then((_) => _fetchProductsFromLocalBackend());
            },
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildHeader(int productCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SellerHomePage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: _accentColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Products',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _accentColor),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$productCount Product',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: Color(0xFF9098B1), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search product',
                  hintStyle: TextStyle(color: Color(0xFF9098B1), fontSize: 14, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () => _searchController.clear(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.close_rounded, color: Color(0xFF9098B1), size: 20),
                ),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'label': 'Semua', 'value': null},
      {'label': 'Approved', 'value': 'approved'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Rejected', 'value': 'rejected'},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final value = filter['value'] as String?;
          final isSelected = _selectedFilter == value;
          final count = _countByStatus(value);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = value;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _primaryBlue : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.3) : _primaryBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : _primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // PRODUCT CARD
  // ----------------------------------------------------------
  Widget _buildProductCard(Map<String, dynamic> product, ProductController controller) {
    final String title = product['nama_produk'] ?? product['title'] ?? '-';
    final dynamic rawPrice = product['harga'] ?? product['price'] ?? 0;
    final String? imageUrl = product['file_path'] ?? product['image'];
    
    // Status
    final effectiveStatus = _getEffectiveStatus(product['status']);

    // Rating & Review
    final dynamic rawRating = product['reviews_avg_rating'] ?? product['rating'] ?? 0.0;
    final double rating = rawRating is num ? rawRating.toDouble() : (double.tryParse(rawRating.toString()) ?? 0.0);
    final int reviewCount = product['reviews_count'] ?? 0;

    // Sales
    final dynamic rawSales = product['qty_terjual'] ?? product['total_terjual'] ?? product['terjual'] ?? 0;
    int salesCount = 0;
    if (rawSales is num) {
      salesCount = rawSales.toInt();
    } else {
      String cleanSales = rawSales.toString().replaceAll(RegExp(r'[^0-9]'), '');
      salesCount = int.tryParse(cleanSales) ?? 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 80,
              height: 80,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? imageUrl.startsWith('http')
                      ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder())
                      : Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder())
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1D2E)),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatRupiah(rawPrice),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _primaryBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  '$salesCount sales',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7380), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildStarRating(rating),
                    const SizedBox(width: 4),
                    Text(
                      '${rating.toStringAsFixed(1)} ($reviewCount)',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9098B1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Badge Status & Tombol Edit/Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor(effectiveStatus),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(effectiveStatus),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(effectiveStatus),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Kumpulan Tombol
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => EditProductPage(product: product))
                      ).then((_) => _fetchProductsFromLocalBackend());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: _primaryBlue, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context, product, controller),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == null ? 'Product not found' : 'Tidak ada produk ${_statusLabel(_selectedFilter)}', 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9098B1))
          ),
          const SizedBox(height: 8),
          const Text('Try changing your search terms or filter', style: TextStyle(fontSize: 13, color: Color(0xFFB0B8CC))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedFilter = null);
            },
            child: const Text('Reset pencarian', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFFFB800), size: 13);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: Color(0xFFFFB800), size: 13);
        } else {
          return const Icon(Icons.star_border, color: Color(0xFFD0D5E8), size: 13);
        }
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> product, ProductController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Product "${product['nama_produk'] ?? product['title']}" will be permanently removed.', style: const TextStyle(color: Color(0xFF9098B1))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Color(0xFF9098B1)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteProduct((product['produk_id'] ?? product['id'] ?? '').toString());
              _fetchProductsFromLocalBackend();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product['nama_produk'] ?? product['title']} deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0F2F8),
      child: const Icon(Icons.image_rounded, color: Color(0xFFB0B8CC), size: 32),
    );
  }
}