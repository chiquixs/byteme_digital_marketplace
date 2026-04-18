import 'package:flutter/material.dart';

// ============================================================
// HOME PAGE - Digital Product Marketplace
// Letakkan file ini di: lib/views/home/home_page.dart
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Daftar halaman untuk bottom navigation bar
  final List<Widget> _pages = [
    const HomeContent(),
    const ExplorePage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.explore_rounded, 'Explore'),
              _buildNavItem(2, Icons.shopping_bag_rounded, 'Cart'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B7FD7).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF6B7FD7)
                  : const Color(0xFFB0B8CC),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF6B7FD7)
                    : const Color(0xFFB0B8CC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME CONTENT - Konten utama halaman Home
// ============================================================
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // ⚠️ DATA PRODUK - Ganti path gambar sesuai aset kamu
  static const List<Map<String, dynamic>> _products = [
    {
      'title': 'E-Book Material',
      'reviews': '1.2k Reviews',
      'rating': 4.0,
      'price': 'Rp 59.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/ebook_material.png
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Girls E-Book',
      'reviews': '1.3k Reviews',
      'rating': 4.0,
      'price': 'Rp 78.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/girls_ebook.png
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'UI Kit Pro',
      'reviews': '980 Reviews',
      'rating': 4.5,
      'price': 'Rp 120.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/uikit_pro.png
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Design Template',
      'reviews': '765 Reviews',
      'rating': 4.0,
      'price': 'Rp 45.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/design_template.png
      'image': 'assets/images/e-book.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildBannerPromo(),
                  const SizedBox(height: 28),
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildProductCard(_products[index], context),
                childCount: _products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.60,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER: Greeting + Avatar + Wishlist
  // ----------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      children: [
        // ⚠️ GANTI: Simpan foto profil di assets/images/avatar.png
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFD0D5E8),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile.jpeg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                color: Color(0xFF6B7FD7),
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Hi! ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                Text('🧡', style: TextStyle(fontSize: 18)),
              ],
            ),
            const Text(
              'Lagi cari apa?',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9098B1),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Tombol Wishlist / Favorit
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            color: Color(0xFFFF4D67),
            size: 22,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SEARCH BAR
  // ----------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
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
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search digital product',
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
          Container(
            width: 1,
            height: 24,
            color: const Color(0xFFE8ECF4),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.tune, color: Color(0xFF6B7FD7), size: 22),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // BANNER PROMO
  // ----------------------------------------------------------
  Widget _buildBannerPromo() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C8FE0), Color(0xFF9FB3F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran latar belakang
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Gambar banner kanan — memenuhi sisi kanan dengan proporsi terjaga
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(20),
              ),
              child: SizedBox(
                width: 140,
                child: Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.15),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Teks dan tombol
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Get 30% off on UI Kits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Limited time offer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                  label: const Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6B7FD7),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SECTION HEADER: Best Seller Product + more
  // ----------------------------------------------------------
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Best Seller Product',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1D2E),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'more >',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7FD7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // PRODUCT CARD
  // ----------------------------------------------------------
  Widget _buildProductCard(
      Map<String, dynamic> product, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk — Expanded agar mengisi ruang tanpa overflow
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  product['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF0F2F8),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          color: Color(0xFFB0B8CC),
                          size: 36,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Belum ada\ngambar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB0B8CC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Info produk
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStarRating(product['rating']),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product['reviews'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9098B1),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol Add to Cart
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product['title']} ditambahkan ke keranjang!'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF6B7FD7),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7FD7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFFFB800), size: 12);
        } else if (i < rating) {
          return const Icon(Icons.star_half,
              color: Color(0xFFFFB800), size: 12);
        } else {
          return const Icon(Icons.star_border,
              color: Color(0xFFD0D5E8), size: 12);
        }
      }),
    );
  }
}

// ============================================================
// EXPLORE PAGE - Halaman Explore (placeholder)
// Pindahkan ke: lib/views/product/product_list_page.dart
// ============================================================
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F2F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_rounded, size: 64, color: Color(0xFF6B7FD7)),
            SizedBox(height: 16),
            Text(
              'Explore',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Temukan produk digital terbaik',
              style: TextStyle(color: Color(0xFF9098B1)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CART PAGE - Halaman Keranjang (placeholder)
// Pindahkan ke: lib/views/ (buat halaman cart sendiri)
// ============================================================
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F2F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_rounded,
                size: 64, color: Color(0xFF6B7FD7)),
            SizedBox(height: 16),
            Text(
              'Keranjang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Belum ada produk di keranjang',
              style: TextStyle(color: Color(0xFF9098B1)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE PAGE - Halaman Profil (placeholder)
// Pindahkan ke: lib/views/profile/profile_page.dart
// ============================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F2F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_rounded, size: 64, color: Color(0xFF6B7FD7)),
            SizedBox(height: 16),
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kelola akun dan pengaturanmu',
              style: TextStyle(color: Color(0xFF9098B1)),
            ),
          ],
        ),
      ),
    );
  }
}
