// ============================================================
// SELLER PRODUCT PAGE
// Letakkan file ini di: lib/views/seller/product/product_page.dart
// ============================================================

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

// ============================================================
// SELLER PRODUCT PAGE
// ============================================================
class SellerProductPage extends StatefulWidget {
  const SellerProductPage({super.key, required void Function() onBackPressed});

  @override
  State<SellerProductPage> createState() => _SellerProductPageState();
}

class _SellerProductPageState extends State<SellerProductPage> {
  // ── WARNA UTAMA (sama dengan seller/home/home_page.dart) ──
  static const Color _accentColor = Color(0xFF3D4270);
  static const Color _primaryBlue = Color(0xFF6B7FD7);
  static const Color _bgColor = Color(0xFFE8E8F0);

  // ── SEARCH ──
  // Meniru pola _searchController di explore_page.dart
  final TextEditingController _searchController = TextEditingController();

  // _filteredProducts dihitung dari data controller, bukan disimpan lokal
  List<Map<String, dynamic>> _filteredProducts = [];

  // ──────────────────────────────────────────
  // LIFECYCLE
  // Meniru pola initState & dispose di explore_page.dart
  // ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);

    // Jalankan filter pertama kali setelah frame pertama selesai render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // FILTER LOGIC — hanya berdasarkan search query (filter tab dihapus)
  // Meniru pola _applyFilter di explore_page.dart
  // ──────────────────────────────────────────
  void _applyFilter() {
    final allProducts = context.read<ProductController>().products;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = allProducts.where((p) {
        return (p['title'] as String).toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showComingSoonSnackbar(String page) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The $page page has not been created yet'),
        backgroundColor: _primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ──────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _applyFilter();
        });

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                // ── Filter tab Active/Inactive DIHAPUS ──
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(
                              _filteredProducts[index],
                              productController,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── TOMBOL TAMBAH PRODUK ──
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Meniru pola Navigator.push di seller/home/home_page.dart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              );
            },
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add New Product',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // Meniru pola _buildHeader di versi sebelumnya
  // ----------------------------------------------------------
  Widget _buildHeader() {
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _accentColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Products',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _accentColor,
            ),
          ),
          const Spacer(),
          // Badge jumlah produk
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredProducts.length} Product',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SEARCH BAR
  // Meniru pola _buildSearchBar di explore_page.dart
  // ----------------------------------------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
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
                  hintStyle: TextStyle(
                    color: Color(0xFF9098B1),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
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
                  child:
                      Icon(Icons.close_rounded, color: Color(0xFF9098B1), size: 20),
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
  // PRODUCT CARD
  // Badge status & toggle dihapus, titik tiga hanya Edit & Delete
  // ----------------------------------------------------------
  Widget _buildProductCard(
    Map<String, dynamic> product,
    ProductController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── GAMBAR PRODUK ──
          // Meniru pola Image.asset + errorBuilder di buyer/home/home_page.dart
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                product['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF0F2F8),
                    child: const Icon(
                      Icons.image_rounded,
                      color: Color(0xFFB0B8CC),
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── INFO PRODUK ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1D2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['sales'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                // Rating bintang
                Row(
                  children: [
                    _buildStarRating(product['rating']),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9098B1)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── KANAN: hanya tombol titik tiga (badge status & toggle dihapus) ──
          GestureDetector(
            onTap: () => _showProductOptions(context, product, controller),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.more_horiz_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // EMPTY STATE
  // Meniru pola _buildEmptyState di explore_page.dart
  // ----------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Product not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9098B1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your search terms',
            style: TextStyle(fontSize: 13, color: Color(0xFFB0B8CC)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _searchController.clear(),
            child: const Text(
              'Reset pencarian',
              style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // STAR RATING
  // Meniru pola _buildStarRating di buyer/home/home_page.dart
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // POPUP TITIK TIGA — hanya Edit & Delete (toggle status dihapus)
  // Meniru pola showModalBottomSheet di versi sebelumnya
  // ----------------------------------------------------------
  void _showProductOptions(
    BuildContext context,
    Map<String, dynamic> product,
    ProductController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E4F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 20),

            // ── Edit Product → navigasi ke EditProductPage ──
            _buildOptionButton(
              icon: Icons.edit_rounded,
              label: 'Edit Product',
              color: _primaryBlue,
              onTap: () {
                Navigator.pop(context); // tutup bottom sheet dulu
                // Meniru pola Navigator.push di seller/home/home_page.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProductPage(product: product),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // ── Delete Product ──
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

  // ── Dialog konfirmasi hapus ──
  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> product,
    ProductController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Product "${product['title']}" will be permanently removed.',
          style: const TextStyle(color: Color(0xFF9098B1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF9098B1))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteProduct(product['title']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product['title']} deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Helper tombol opsi bottom sheet ──
  // Meniru pola _buildOptionButton di versi sebelumnya
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}