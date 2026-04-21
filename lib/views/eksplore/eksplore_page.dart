import 'package:flutter/material.dart';

// ============================================================
// EXPLORE PAGE - Digital Product Marketplace
// Letakkan file ini di: lib/views/eksplore/eksplore_page.dart
// ============================================================

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // ⚠️ DATA PRODUK - Ganti path gambar sesuai aset kamu
  static const List<Map<String, dynamic>> _products = [
    {
      'title': 'E-Book Material',
      'category': 'E-BOOK',
      'reviews': '1.2k Reviews',
      'rating': 4.5,
      'price': 'Rp 59.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/e-book.jpeg
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Girls E-Book',
      'category': 'E-BOOK',
      'reviews': '1.3k Reviews',
      'rating': 4.0,
      'price': 'Rp 78.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/girls-ebook.jpeg
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'UI Kit Pro',
      'category': 'TEMPLATE',
      'reviews': '980 Reviews',
      'rating': 4.5,
      'price': 'Rp 120.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/uikit-pro.jpeg
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Design Template',
      'category': 'TEMPLATE',
      'reviews': '765 Reviews',
      'rating': 4.0,
      'price': 'Rp 45.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/design-template.jpeg
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Flutter Course',
      'category': 'KURSUS',
      'reviews': '2.1k Reviews',
      'rating': 5.0,
      'price': 'Rp 199.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/flutter-course.jpeg
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Notion Template',
      'category': 'TEMPLATE',
      'reviews': '540 Reviews',
      'rating': 4.0,
      'price': 'Rp 35.000',
      // ⚠️ GANTI: Simpan gambar di assets/images/notion-template.jpeg
      'image': 'assets/images/e-book.jpeg',
    },
  ];

  // Daftar kategori filter
  static const List<String> _categories = [
    'Semua',
    'E-BOOK',
    'TEMPLATE',
    'KURSUS',
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = _products;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((p) {
        final matchQuery =
            (p['title'] as String).toLowerCase().contains(query) ||
            (p['category'] as String).toLowerCase().contains(query);
        final matchCategory = _selectedCategory == 'Semua' ||
            p['category'] == _selectedCategory;
        return matchQuery && matchCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildHeader(),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),
          // Filter Kategori
          _buildCategoryFilter(),
          const SizedBox(height: 16),
          // Grid Produk
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER: Judul + Jumlah produk
  // ----------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Explore',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1D2E),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6B7FD7).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_filteredProducts.length} Produk',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7FD7),
            ),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
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
          GestureDetector(
            onTap: _showFilterSheet,
            child: const Icon(Icons.tune, color: Color(0xFF6B7FD7), size: 22),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // FILTER KATEGORI (chip horizontal)
  // ----------------------------------------------------------
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              _applyFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B7FD7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF9098B1),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // GRID PRODUK
  // ----------------------------------------------------------
  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.60,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) =>
          _buildProductCard(_filteredProducts[index], context),
    );
  }

  // ----------------------------------------------------------
  // EMPTY STATE
  // ----------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
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
            'Coba kata kunci lain',
            style: TextStyle(fontSize: 13, color: Color(0xFFB0B8CC)),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // FILTER BOTTOM SHEET
  // ----------------------------------------------------------
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final bool isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _applyFilter();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6B7FD7)
                          : const Color(0xFFF0F2F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9098B1),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7FD7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Terapkan Filter'),
              ),
            ),
          ],
        ),
      ),
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
          // Gambar produk dari assets/images/
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
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
                  // Badge kategori
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7FD7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product['category'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
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

  // ----------------------------------------------------------
  // STAR RATING
  // ----------------------------------------------------------
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