// ============================================================
// SELLER PRODUCT PAGE
// Letakkan file ini di: lib/views/seller/product_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── Import ProductController ──
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart';

// ── Import halaman seller lain untuk navigasi bottom bar ──
import 'package:byteme_digital_marketplace/views/seller/home/home_page.dart';
// TODO: Uncomment import di bawah ini setelah halaman-halaman tersebut dibuat:
// import 'package:byteme_digital_marketplace/views/seller/order/order_page.dart';
// import 'package:byteme_digital_marketplace/views/seller/earnings/earnings_page.dart';
// import 'package:byteme_digital_marketplace/views/seller/profile/profile_page.dart';

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

  // ── INDEX TAB BOTTOM NAV (Product = index 1) ──
  int _currentIndex = 1;

  // ── FILTER TAB: 0=All, 1=Active, 2=Inactive ──
  int _selectedFilter = 0;

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

    // Jalankan filter pertama kali setelah frame pertama selesai render,
    // agar context.read sudah tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter); // lepas listener dulu
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // FILTER LOGIC
  // Meniru pola void _applyFilter() di explore_page.dart
  // Bedanya: sumber data diambil dari ProductController, bukan list lokal
  // ──────────────────────────────────────────
  void _applyFilter() {
    // Ambil data terbaru dari controller (selalu up-to-date)
    final allProducts = context.read<ProductController>().products;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = allProducts.where((p) {
        // Filter berdasarkan teks search
        final matchQuery =
            (p['title'] as String).toLowerCase().contains(query);

        // Filter berdasarkan tab (All / Active / Inactive)
        final matchStatus = _selectedFilter == 0 ||
            (_selectedFilter == 1 && p['status'] == 'active') ||
            (_selectedFilter == 2 && p['status'] == 'inactive');

        return matchQuery && matchStatus;
      }).toList();
    });
  }

  // ──────────────────────────────────────────
  // NAVIGASI BOTTOM NAV
  // Meniru pola _switchTab di buyer/home/home_page.dart
  // ──────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerHomePage()),
        );
        break;
      case 1:
        break;
      case 2:
        // TODO: Navigator.pushReplacement ke SellerOrderPage
        _showComingSoonSnackbar('Order');
        break;
      case 3:
        // TODO: Navigator.pushReplacement ke SellerEarningsPage
        _showComingSoonSnackbar('Earnings');
        break;
      case 4:
        // TODO: Navigator.pushReplacement ke SellerProfilePage
        _showComingSoonSnackbar('Profile');
        break;
    }
  }

  void _showComingSoonSnackbar(String page) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Halaman $page belum dibuat'),
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
    // Consumer meniru pola Consumer<UserController> di buyer/home/home_page.dart
    // Widget otomatis rebuild saat ProductController memanggil notifyListeners()
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        // Setiap kali controller berubah (toggle/delete), filter dijalankan ulang
        // agar _filteredProducts selalu sinkron dengan data terbaru
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
                _buildFilterTabs(),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
            onPressed: () => _showComingSoonSnackbar('Add Product'),
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              '+ Add New Product',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,

          // ── BOTTOM NAVIGATION BAR ──
          // Meniru pola bottomNavigationBar di seller/home/home_page.dart
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: _primaryBlue,
                unselectedItemColor: Colors.grey.shade400,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                currentIndex: _currentIndex,
                onTap: _onNavTap,
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.home_rounded, size: 28),
                    ),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.grid_view_rounded, size: 26),
                    ),
                    label: 'Product',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.shopping_bag_outlined, size: 26),
                    ),
                    label: 'My Order',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.ios_share_rounded, size: 26),
                    ),
                    label: 'Earnings',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(Icons.person_rounded, size: 28),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          // Tombol back → pushReplacement ke SellerHomePage
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
          // Badge jumlah produk — meniru pola badge di explore_page.dart
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredProducts.length} Produk',
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
                // Tidak pakai onChanged — sudah pakai addListener di initState
                // Meniru pola: _searchController.addListener(_applyFilter) di explore_page.dart
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
            // Tombol X — clear() otomatis trigger listener → _applyFilter()
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () => _searchController.clear(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF9098B1), size: 20),
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
  // FILTER TABS (All / Active / Inactive)
  // ----------------------------------------------------------
  Widget _buildFilterTabs() {
    final List<String> tabs = ['All Products', 'Active', 'Inactive'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final bool isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = index);
              _applyFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ----------------------------------------------------------
  // PRODUCT CARD
  // Meniru pola _buildProductItem di seller/home/home_page.dart
  // dan Image.asset + errorBuilder di buyer/home/home_page.dart
  // ----------------------------------------------------------
  Widget _buildProductCard(
    Map<String, dynamic> product,
    ProductController controller,
  ) {
    final bool isActive = product['status'] == 'active';

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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                // Rating bintang
                // Meniru pola _buildStarRating di buyer/home/home_page.dart
                Row(
                  children: [
                    _buildStarRating(product['rating']),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9098B1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── KANAN: Titik tiga + Badge Status ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () =>
                    _showProductOptions(context, product, controller),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4CAF50).withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
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
          Icon(Icons.search_off_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9098B1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba ubah filter atau kata kunci',
            style: TextStyle(fontSize: 13, color: Color(0xFFB0B8CC)),
          ),
          const SizedBox(height: 16),
          // Meniru pola TextButton reset di explore_page.dart
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedFilter = 0);
              _applyFilter();
            },
            child: const Text(
              'Reset semua filter',
              style: TextStyle(
                color: _primaryBlue,
                fontWeight: FontWeight.w600,
              ),
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
          return const Icon(Icons.star_half,
              color: Color(0xFFFFB800), size: 13);
        } else {
          return const Icon(Icons.star_border,
              color: Color(0xFFD0D5E8), size: 13);
        }
      }),
    );
  }

  // ----------------------------------------------------------
  // POPUP TITIK TIGA
  // Meniru pola showModalBottomSheet di explore_page.dart
  // ----------------------------------------------------------
  void _showProductOptions(
    BuildContext context,
    Map<String, dynamic> product,
    ProductController controller,
  ) {
    final bool isActive = product['status'] == 'active';

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
            // Handle bar — meniru handle bar di _FilterSheet explore_page.dart
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
            const SizedBox(height: 4),
            Text(
              isActive ? '● Active' : '● Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? const Color(0xFF4CAF50)
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // ── Edit ──
            _buildOptionButton(
              icon: Icons.edit_rounded,
              label: 'Edit Product',
              color: _primaryBlue,
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar('Edit Product');
              },
            ),
            const SizedBox(height: 10),

            // ── Toggle Status ──
            // Memanggil controller.toggleStatus() → notifyListeners()
            // → Consumer rebuild → _applyFilter() → tampilan diperbarui
            _buildOptionButton(
              icon: isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              label: isActive ? 'Set Inactive' : 'Set Active',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                controller.toggleStatus(product['title']); // simpan ke controller
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isActive
                          ? '${product['title']} dinonaktifkan'
                          : '${product['title']} diaktifkan',
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // ── Delete ──
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

  // ── Dialog konfirmasi sebelum hapus ──
  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> product,
    ProductController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Produk "${product['title']}" akan dihapus secara permanen.',
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
              controller.deleteProduct(product['title']); // simpan ke controller
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product['title']} dihapus'),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ── Helper tombol opsi bottom sheet ──
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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