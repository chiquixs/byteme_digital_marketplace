// ============================================================
// SELLER PRODUCT PAGE - 100% Full Verified (Sales & Ratings)
// Letakkan file ini di: lib/views/seller/product/product_page.dart
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── Import ProductController ──
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart';

// ── Import halaman seller lain untuk navigasi ──
import 'package:byteme_digital_marketplace/views/seller/home/home_page.dart';

// ── Import AddProductPage untuk tombol FAB ──
import 'package:byteme_digital_marketplace/views/seller/product/add_product.dart';

// ── Import EditProductPage untuk navigasi dari titik tiga ──
import 'package:byteme_digital_marketplace/views/seller/product/edit_product.dart';

// ── Import ApiService untuk bypass localhost ──
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

  // Mengambil data langsung dari backend lokal (Sinkron dengan Dashboard)
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

  // HELPER FORMAT RUPIAH AGAR TAMPILAN CANTIK
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        final allProducts = _localProducts;
        final query = _searchController.text.toLowerCase();
        
        final filteredProducts = allProducts.where((p) {
          final title = (p['nama_produk'] ?? p['title'] ?? '').toString().toLowerCase();
          return title.contains(query);
        }).toList();

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(filteredProducts.length),
                _buildSearchBar(),

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

  // ----------------------------------------------------------
  // PRODUCT CARD - REAL DATA WITH RATING CORRECTION
  // ----------------------------------------------------------
  Widget _buildProductCard(Map<String, dynamic> product, ProductController controller) {
    final String title = product['nama_produk'] ?? product['title'] ?? '-';
    final dynamic rawPrice = product['harga'] ?? product['price'] ?? 0;
    final String? imageUrl = product['file_path'] ?? product['image'];

    // 🌟 SEKARANG SUDAH MENGGUNAKAN KEY REAL DARI LARAVEL WITHAVG
    final dynamic rawRating = product['reviews_avg_rating'] ?? product['rating'] ?? 0.0;
    final double rating = rawRating is num ? rawRating.toDouble() : (double.tryParse(rawRating.toString()) ?? 0.0);

    // Menghitung jumlah reviewer asli database
    final int reviewCount = product['reviews_count'] ?? 0;

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(rawPrice),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primaryBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  '$salesCount sales',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7380), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                
                // 🌟 BINTANG RATING SEKARANG SUDAH TEMBUS REAL-TIME SINKRON
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
          GestureDetector(
            onTap: () => _showProductOptions(context, product, controller),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400, size: 22),
            ),
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
          const Text('Product not found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9098B1))),
          const SizedBox(height: 8),
          const Text('Try changing your search terms', style: TextStyle(fontSize: 13, color: Color(0xFFB0B8CC))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _searchController.clear(),
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

  void _showProductOptions(BuildContext context, Map<String, dynamic> product, ProductController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              child: Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0E4F0), borderRadius: BorderRadius.circular(2))),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product['nama_produk'] ?? product['title'] ?? 'Product',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _accentColor),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              icon: Icons.edit_rounded,
              label: 'Edit Product',
              color: _primaryBlue,
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => EditProductPage(product: product))
                ).then((_) => _fetchProductsFromLocalBackend());
              },
            ),
            const SizedBox(height: 10),
            _buildOptionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Product',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, product, controller);
              },
            ),
          ],
        ),
      ),
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

  Widget _buildOptionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}