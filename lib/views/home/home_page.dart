import 'package:flutter/material.dart';
import '../cart/cart_page.dart';
import '../profile/profile_page.dart';
import '../eksplore/eksplore_page.dart';

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
// HOME CONTENT - Konten utama halaman Home
// Diubah dari StatelessWidget → StatefulWidget untuk filter state
// ============================================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // ──────────────────────────────────────────
  // FILTER STATE
  // Semua state filter dikumpulkan di sini agar mudah
  // dihubungkan ke backend/controller nanti.
  // ──────────────────────────────────────────

  /// Apakah filter section sedang terbuka
  bool _isFilterOpen = false;

  /// Kategori yang sedang dipilih (null = belum pilih)
  /// TODO(backend): Kirim nilai ini ke ProductController.filterByCategory()
  String? _selectedCategory;

  /// Range harga yang sedang dipilih (null = belum pilih)
  /// TODO(backend): Kirim nilai ini ke ProductController.filterByPrice()
  String? _selectedPriceRange;

  /// Rating minimum yang sedang dipilih (null = belum pilih)
  /// TODO(backend): Kirim nilai ini ke ProductController.filterByRating()
  int? _selectedRating;

  // ──────────────────────────────────────────
  // DATA FILTER OPTION
  // Ganti/tambah value di sini sesuai kebutuhan backend
  // ──────────────────────────────────────────
  static const List<String> _categoryOptions = [
    'E-book',
    'Canva Template',
    'Excel Template',
    'UI/UX',
    'Photo Stock',
    'PDF Template',
    'Website Plugin',
    'Audio / Music',
    'Software',
    'Font',
    'NFT',
    'Domain',
  ];

  static const List<String> _priceRangeOptions = [
    '< 50.000',
    '50.000-100.000',
    '100.000-150.000',
    '> 150.000',
  ];

  // ──────────────────────────────────────────
  // ⚠️ DATA PRODUK - Ganti path gambar sesuai aset kamu
  // ──────────────────────────────────────────
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

  /// Reset semua filter ke kondisi awal
  /// TODO(backend): Panggil ProductController.clearFilters() di sini
  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedPriceRange = null;
      _selectedRating = null;
    });
  }

  /// Cek apakah ada filter yang sedang aktif
  bool get _hasActiveFilter =>
      _selectedCategory != null ||
      _selectedPriceRange != null ||
      _selectedRating != null;

  /// Terapkan filter — siap dihubungkan ke controller
  /// TODO(backend): Panggil ProductController.applyFilters() di sini
  void _applyFilters() {
    // Contoh nanti:
    // context.read<ProductController>().applyFilters(
    //   category: _selectedCategory,
    //   priceRange: _selectedPriceRange,
    //   minRating: _selectedRating,
    // );
    setState(() => _isFilterOpen = false);
  }

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
                  // Filter panel — expand/collapse saat tombol filter diklik
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isFilterOpen
                        ? _buildFilterSection()
                        : const SizedBox.shrink(),
                  ),
                  // Active filter chips — muncul setelah Apply Filter
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _hasActiveFilter && !_isFilterOpen
                        ? _buildActiveFilterChips()
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  _buildBannerPromo(),
                  const SizedBox(height: 28),
                  // _buildSectionHeader(),
                  // const SizedBox(height: 16),
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
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: Color(0xFF6B7FD7), size: 28),
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
          child: const Icon(Icons.favorite, color: Color(0xFFFF4D67), size: 22),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SEARCH BAR + TOMBOL FILTER
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
              // TODO(backend): Hubungkan controller ini ke ProductController.searchQuery
              // controller: searchController,
              // onChanged: (val) => context.read<ProductController>().search(val),
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
          Container(width: 1, height: 24, color: const Color(0xFFE8ECF4)),
          const SizedBox(width: 4),
          // ── TOMBOL FILTER ──
          GestureDetector(
            onTap: () => setState(() => _isFilterOpen = !_isFilterOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Icon(
                Icons.tune,
                // Icon berubah warna: merah kalau ada filter aktif tapi panel tutup
                color: _isFilterOpen
                    ? const Color(0xFF6B7FD7)
                    : (_selectedCategory != null ||
                            _selectedPriceRange != null ||
                            _selectedRating != null)
                        ? const Color(0xFFFF4D67)
                        : const Color(0xFF6B7FD7),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // FILTER SECTION
  // ----------------------------------------------------------
  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── CATEGORY ──
          _buildFilterLabel('Category'),
          const SizedBox(height: 10),
          // TODO(backend): _selectedCategory dikirim ke controller saat apply
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryOptions.map((category) {
              final bool isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = isSelected ? null : category;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B7FD7)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6B7FD7)
                          : const Color(0xFFD0D5E8),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7FD7),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0F2F8), thickness: 1),
          const SizedBox(height: 12),

          // ── PRICE ──
          _buildFilterLabel('Price'),
          const SizedBox(height: 10),
          // TODO(backend): _selectedPriceRange dikirim ke controller saat apply
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _priceRangeOptions.map((range) {
              final bool isSelected = _selectedPriceRange == range;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedPriceRange = isSelected ? null : range;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B7FD7)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6B7FD7)
                          : const Color(0xFFD0D5E8),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    range,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7FD7),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0F2F8), thickness: 1),
          const SizedBox(height: 12),

          // ── RATING ──
          _buildFilterLabel('Rating'),
          const SizedBox(height: 10),
          // TODO(backend): _selectedRating dikirim ke controller saat apply
          Row(
            children: List.generate(5, (i) {
              final int starValue = i + 1;
              final bool isSelected = _selectedRating == starValue;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedRating = isSelected ? null : starValue;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B7FD7)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6B7FD7)
                          : const Color(0xFFD0D5E8),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$starValue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7FD7),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFFB800),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // ── TOMBOL RESET & APPLY ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  // TODO(backend): _resetFilters() juga panggil controller.clearFilters()
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD0D5E8)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF9098B1),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  // TODO(backend): _applyFilters() panggil controller.applyFilters()
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7FD7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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
  // ACTIVE FILTER CHIPS
  // Muncul di bawah search bar setelah Apply Filter ditekan
  // ----------------------------------------------------------
  Widget _buildActiveFilterChips() {
    // Kumpulkan semua filter aktif jadi list of string
    // TODO(backend): List ini bisa di-generate dari ProductController.activeFilters
    final List<String> activeChips = [
      if (_selectedCategory != null) _selectedCategory!,
      if (_selectedPriceRange != null) _selectedPriceRange!,
      if (_selectedRating != null) '${_selectedRating!}★',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label "Result for :"
          const Text(
            'Result for :',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 8),
          // Baris chip + tombol X
          Row(
            children: [
              // Chips filter aktif (scrollable kalau banyak)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: activeChips.map((chip) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B7FD7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol X — clear semua filter
              // TODO(backend): Panggil juga ProductController.clearFilters() di sini
              GestureDetector(
                onTap: _resetFilters,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF9098B1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1D2E),
      ),
    );
  }

  // ----------------------------------------------------------
  // BANNER PROMO
  // ----------------------------------------------------------
  Widget _buildBannerPromo() {
    return Container(
      width: double.infinity,
      // Hapus baris height: 150, agar fleksibel
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C8FE0), Color(0xFF9FB3F5)],
        ),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Tambahkan ini agar Column tidak rakus ruang
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get 30% off on UI Kits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Limited time offer',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6B7FD7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PRODUCT CARD
  // ----------------------------------------------------------
  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
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
          // Info produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            '${product['title']} ditambahkan ke keranjang!',
                          ),
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
          return const Icon(
            Icons.star_half,
            color: Color(0xFFFFB800),
            size: 12,
          );
        } else {
          return const Icon(
            Icons.star_border,
            color: Color(0xFFD0D5E8),
            size: 12,
          );
        }
      }),
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
