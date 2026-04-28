import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import '../cart/cart_page.dart';
import '../profile/profile_page.dart';
import '../eksplore/eksplore_page.dart';
import '../product/product_detail_page.dart';
import '../wishlist/wishlist_page.dart';
import '../../../utils/buyer/cart_manager.dart';

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

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _pages => [
    HomeContent(onNavigateToExplore: () => _switchTab(1)),
    const ExplorePage(),
    CartPage(onBack: () => _switchTab(0)),
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
// HOME CONTENT
// ============================================================
class HomeContent extends StatefulWidget {
  final VoidCallback? onNavigateToExplore;
  const HomeContent({super.key, this.onNavigateToExplore});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // ── AUTO-SCROLL BANNER ──
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  // ── DATA BANNER PROMO ──
  // TODO(backend): Ganti dengan data dari API / controller
  static const List<Map<String, dynamic>> _banners = [
    {
      'title': 'Get 30% off on UI Kits',
      'subtitle': 'Limited time offer',
      'gradient': [Color(0xFF7C8FE0), Color(0xFF9FB3F5)],
      'icon': Icons.dashboard_customize_rounded,
    },
    {
      'title': 'E-Book Terlaris Minggu Ini',
      'subtitle': 'Ratusan judul tersedia',
      'gradient': [Color(0xFF5E9EF5), Color(0xFF8FC3F9)],
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Canva Template Premium',
      'subtitle': 'Mulai dari Rp 25.000',
      'gradient': [Color(0xFFB07FD7), Color(0xFFD4A8F5)],
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  // ── DATA PRODUK PALING BANYAK DIBELI ──
  // TODO(backend): Ambil dari ProductController.getMostPurchased()
  static const List<Map<String, dynamic>> _mostPurchased = [
    {
      'title': 'UI Kit Pro',
      'category': 'UI/UX',
      'rating': 4.5,
      'reviews': '2.1k',
      'price': 'Rp 120.000',
      'image': 'assets/images/e-book.jpeg',
      'badge': '🔥 Terlaris',
    },
    {
      'title': 'E-Book Material',
      'category': 'E-book',
      'rating': 4.0,
      'reviews': '1.2k',
      'price': 'Rp 59.000',
      'image': 'assets/images/e-book.jpeg',
      'badge': '⭐ Top Pick',
    },
    {
      'title': 'Canva Bundle',
      'category': 'Canva Template',
      'rating': 4.8,
      'reviews': '980',
      'price': 'Rp 85.000',
      'image': 'assets/images/e-book.jpeg',
      'badge': '🔥 Terlaris',
    },
  ];

  // ── DATA PRODUK PALING BANYAK DICARI ──
  // TODO(backend): Ambil dari ProductController.getMostSearched()
  static const List<Map<String, dynamic>> _mostSearched = [
    {
      'title': 'Design Template',
      'category': 'PDF Template',
      'rating': 4.0,
      'reviews': '765',
      'price': 'Rp 45.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Girls E-Book',
      'category': 'E-book',
      'rating': 4.0,
      'reviews': '1.3k',
      'price': 'Rp 78.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Font Premium Pack',
      'category': 'Font',
      'rating': 4.3,
      'reviews': '540',
      'price': 'Rp 35.000',
      'image': 'assets/images/e-book.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── HEADER ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildHeader(userController),
                ),
              ),

              // ── BANNER AUTO-SCROLL ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildAutoBanner(),
                ),
              ),

              // ── SECTION: PALING BANYAK DIBELI ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: _buildSectionHeader(
                    'Most Frequently Purchased 🔥',
                    onMore: widget.onNavigateToExplore,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _mostPurchased.length,
                    itemBuilder: (context, index) =>
                        _buildHorizontalProductCard(
                          _mostPurchased[index],
                          context,
                        ),
                  ),
                ),
              ),

              // ── SECTION: PALING BANYAK DICARI ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: _buildSectionHeader(
                    ' Most Searched 🔍',
                    onMore: widget.onNavigateToExplore,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildGridProductCard(_mostSearched[index], context),
                    childCount: _mostSearched.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.60,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------
  Widget _buildHeader(UserController userController) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFD0D5E8),
          child: ClipOval(
            child: userController.profileImagePath != null
                ? Image.file(
                    File(userController.profileImagePath!),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: Color(0xFF6B7FD7),
                      size: 28,
                    ),
                  )
                : Image.asset(
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
              children: [
                Text(
                  'Hi, ${userController.username.split(' ').first}! ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const Text('🧡', style: TextStyle(fontSize: 18)),
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
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistPage()),
          ),
          child: Container(
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
            child: const Icon(Icons.favorite, color: Color(0xFFFF4D67), size: 22),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // AUTO-SCROLL BANNER
  // ----------------------------------------------------------
  Widget _buildAutoBanner() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() => _currentBanner = index);
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: List<Color>.from(banner['gradient']),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['subtitle'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6B7FD7),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Shop Now'),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      banner['icon'],
                      color: Colors.white.withOpacity(0.3),
                      size: 80,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // ── DOTS INDICATOR ──
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBanner == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBanner == index
                    ? const Color(0xFF6B7FD7)
                    : const Color(0xFFD0D5E8),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SECTION HEADER (judul + tombol "more")
  // ----------------------------------------------------------
  Widget _buildSectionHeader(String title, {VoidCallback? onMore}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onMore,
          child: const Row(
            children: [
              Text(
                'more',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7FD7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: Color(0xFF6B7FD7),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // HORIZONTAL PRODUCT CARD (untuk section "Paling Banyak Dibeli")
  // ----------------------------------------------------------
  Widget _buildHorizontalProductCard(
    Map<String, dynamic> product,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        ),
      ),
      child: Container(
      width: 155,
      margin: const EdgeInsets.only(right: 14),
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
          // Gambar
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF0F2F8),
                        child: const Icon(
                          Icons.image_rounded,
                          color: Color(0xFFB0B8CC),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge
                if (product['badge'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D2E).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product['badge'],
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['category'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9098B1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product['title'],
                  style: const TextStyle(
                    fontSize: 12,
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
                    Text(
                      '${product['reviews']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9098B1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAddedToCart(context, product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7FD7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
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
    ), // GestureDetector
    );
  }

  // ----------------------------------------------------------
  // GRID PRODUCT CARD (untuk section "Paling Banyak Dicari")
  // ----------------------------------------------------------
  Widget _buildGridProductCard(
    Map<String, dynamic> product,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        ),
      ),
      child: Container(
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
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['category'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9098B1),
                  ),
                ),
                const SizedBox(height: 2),
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
                        '${product['reviews']} Reviews',
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAddedToCart(context, product),
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
    ), // GestureDetector
    );
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------
  void _showAddedToCart(BuildContext context, Map<String, dynamic> product) {
    final added = CartManager.instance.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${product['title']} ditambahkan ke keranjang!'
              : '${product['title']} sudah ada di keranjang',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor:
            added ? const Color(0xFF6B7FD7) : const Color(0xFF9098B1),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFFFB800), size: 12);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: Color(0xFFFFB800), size: 12);
        } else {
          return const Icon(Icons.star_border, color: Color(0xFFD0D5E8), size: 12);
        }
      }),
    );
  }
}
