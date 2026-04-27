import 'package:flutter/material.dart';
import '../product/product_detail_page.dart';
import '../../../utils/buyer/cart_manager.dart';

// ============================================================
// EXPLORE PAGE - Digital Product Marketplace
// ============================================================

class ExplorePage extends StatefulWidget {
  final bool isSellerView;
  
  const ExplorePage({super.key, this.isSellerView = false});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // DATA PRODUK (TETAP SAMA)
  static const List<Map<String, dynamic>> _products = [
    {
      'title': 'E-Book Material',
      'category': 'E-Book',
      'reviews': '1.2k Reviews',
      'rating': 4.0,
      'price': 59000,
      'priceLabel': 'Rp 59.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Girls E-Book',
      'category': 'E-Book',
      'reviews': '1.3k Reviews',
      'rating': 4.0,
      'price': 78000,
      'priceLabel': 'Rp 78.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'UI Kit Pro',
      'category': 'UI/UX',
      'reviews': '980 Reviews',
      'rating': 4.5,
      'price': 120000,
      'priceLabel': 'Rp 120.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Design Template',
      'category': 'Canva Template',
      'reviews': '765 Reviews',
      'rating': 4.0,
      'price': 45000,
      'priceLabel': 'Rp 45.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Flutter Course',
      'category': 'Kursus',
      'reviews': '2.1k Reviews',
      'rating': 5.0,
      'price': 199000,
      'priceLabel': 'Rp 199.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Notion Template',
      'category': 'PDF Template',
      'reviews': '540 Reviews',
      'rating': 4.0,
      'price': 35000,
      'priceLabel': 'Rp 35.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Font Premium Pack',
      'category': 'Font',
      'reviews': '432 Reviews',
      'rating': 4.3,
      'price': 85000,
      'priceLabel': 'Rp 85.000',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Excel Dashboard',
      'category': 'Excel Template',
      'reviews': '310 Reviews',
      'rating': 3.5,
      'price': 65000,
      'priceLabel': 'Rp 65.000',
      'image': 'assets/images/e-book.jpeg',
    },
  ];

  static const List<String> _categoryOptions = [
    'E-Book', 'Canva Template', 'Excel Template', 'UI/UX', 'PDF Template', 'Font', 'Kursus', 'Software', 'Audio / Music', 'NFT',
  ];

  static const List<Map<String, dynamic>> _priceRangeOptions = [
    {'label': '< Rp 50.000', 'min': 0, 'max': 49999},
    {'label': 'Rp 50.000 – 100.000', 'min': 50000, 'max': 100000},
    {'label': 'Rp 100.000 – 150.000', 'min': 100001, 'max': 150000},
    {'label': '> Rp 150.000', 'min': 150001, 'max': 999999},
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = List.from(_products);

  Set<String> _tempSelectedCategories = {};
  String? _tempSelectedPriceRange;
  int? _tempSelectedRating;

  Set<String> _appliedCategories = {};
  String? _appliedPriceRange;
  int? _appliedRating;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((p) {
        final matchQuery = (p['title'] as String).toLowerCase().contains(query) || (p['category'] as String).toLowerCase().contains(query);
        final matchCategory = _appliedCategories.isEmpty || _appliedCategories.contains(p['category']);
        bool matchPrice = true;
        if (_appliedPriceRange != null) {
          final range = _priceRangeOptions.firstWhere((r) => r['label'] == _appliedPriceRange, orElse: () => {'min': 0, 'max': 999999});
          final price = p['price'] as int;
          matchPrice = price >= range['min'] && price <= range['max'];
        }
        final matchRating = _appliedRating == null || (p['rating'] as double) >= _appliedRating!;
        return matchQuery && matchCategory && matchPrice && matchRating;
      }).toList();
    });
  }

  bool get _hasActiveFilter => _appliedCategories.isNotEmpty || _appliedPriceRange != null || _appliedRating != null;
  int get _activeFilterCount => (_appliedCategories.isNotEmpty ? 1 : 0) + (_appliedPriceRange != null ? 1 : 0) + (_appliedRating != null ? 1 : 0);

  void _resetAppliedFilters() {
    setState(() {
      _appliedCategories = {};
      _appliedPriceRange = null;
      _appliedRating = null;
    });
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBgColor = Color(0xFFF0F2F8);

    return Scaffold(
      backgroundColor: pageBgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section (Back button, Title, Search bar)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for Back Button and Header Info
                    Row(
                      children: [
                        if (widget.isSellerView)
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                            ),
                          ),
                        
                        // TITLE EXPLORE
                        const Text(
                          'Explore Products',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E)),
                        ),
                        const Spacer(),
                        
                        // PRODUCT COUNT
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B7FD7).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_filteredProducts.length} Produk',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7FD7)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // SEARCH BAR
                    _buildSearchBar(),
                    
                    // ACTIVE FILTERS
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _hasActiveFilter
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildActiveFilterChips(),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // PRODUCT GRID (Scrollable along with header)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: _filteredProducts.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState())
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: widget.isSellerView ? 0.75 : 0.60,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(_filteredProducts[index], context),
                        childCount: _filteredProducts.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
                hintText: 'Search digital product',
                hintStyle: TextStyle(color: Color(0xFF9098B1), fontSize: 14, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(width: 1, height: 24, color: const Color(0xFFE8ECF4)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Icon(Icons.tune, color: _hasActiveFilter ? const Color(0xFFFF4D67) : const Color(0xFF6B7FD7), size: 22),
                ),
                if (_activeFilterCount > 0)
                  Positioned(
                    top: 2,
                    right: 8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: Color(0xFFFF4D67), shape: BoxShape.circle),
                      child: Center(
                        child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    final List<String> chips = [
      ..._appliedCategories,
      if (_appliedPriceRange != null) _appliedPriceRange!,
      if (_appliedRating != null) '≥ ${_appliedRating!}★',
    ];

    return Row(
      children: [
        const Text('Filter: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1D2E))),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: chips.map((chip) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF6B7FD7), borderRadius: BorderRadius.circular(20)),
                  child: Text(chip, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                );
              }).toList(),
            ),
          ),
        ),
        GestureDetector(
          onTap: _resetAppliedFilters,
          child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.close, size: 18, color: Color(0xFF9098B1))),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Produk tidak ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9098B1))),
          const SizedBox(height: 8),
          const Text('Coba ubah filter atau kata kunci', style: TextStyle(fontSize: 13, color: Color(0xFFB0B8CC))),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () { _searchController.clear(); _resetAppliedFilters(); },
            child: const Text('Reset semua filter', style: TextStyle(color: Color(0xFF6B7FD7), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    _tempSelectedCategories = Set.from(_appliedCategories);
    _tempSelectedPriceRange = _appliedPriceRange;
    _tempSelectedRating = _appliedRating;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => _FilterSheet(
        categoryOptions: _categoryOptions, priceRangeOptions: _priceRangeOptions,
        initialCategories: _tempSelectedCategories, initialPriceRange: _tempSelectedPriceRange, initialRating: _tempSelectedRating,
        onApply: (categories, priceRange, rating) { setState(() { _appliedCategories = categories; _appliedPriceRange = priceRange; _appliedRating = rating; }); _applyFilter(); },
        onReset: () { setState(() { _appliedCategories = {}; _appliedPriceRange = null; _appliedRating = null; }); _applyFilter(); },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(product['image'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF0F2F8), child: const Icon(Icons.image_rounded, color: Color(0xFFB0B8CC), size: 36))),
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF6B7FD7), borderRadius: BorderRadius.circular(8)),
                        child: Text(product['category'], style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [_buildStarRating(product['rating']), const SizedBox(width: 4), Expanded(child: Text(product['reviews'], style: const TextStyle(fontSize: 10, color: Color(0xFF9098B1)), overflow: TextOverflow.ellipsis))]),
                  const SizedBox(height: 4),
                  Text(product['priceLabel'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E))),
                  const SizedBox(height: 8),
                  if (!widget.isSellerView)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final added = CartManager.instance.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(added ? '${product['title']} ditambahkan!' : 'Sudah ada di keranjang'), backgroundColor: added ? const Color(0xFF6B7FD7) : const Color(0xFF9098B1), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7FD7), foregroundColor: Colors.white, elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(children: List.generate(5, (i) {
      if (i < rating.floor()) return const Icon(Icons.star, color: Color(0xFFFFB800), size: 12);
      if (i < rating) return const Icon(Icons.star_half, color: Color(0xFFFFB800), size: 12);
      return const Icon(Icons.star_border, color: Color(0xFFD0D5E8), size: 12);
    }));
  }
}

// ============================================================
// FILTER SHEET
// ============================================================
class _FilterSheet extends StatefulWidget {
  final List<String> categoryOptions;
  final List<Map<String, dynamic>> priceRangeOptions;
  final Set<String> initialCategories;
  final String? initialPriceRange;
  final int? initialRating;
  final void Function(Set<String> categories, String? priceRange, int? rating) onApply;
  final VoidCallback onReset;

  const _FilterSheet({required this.categoryOptions, required this.priceRangeOptions, required this.initialCategories, required this.initialPriceRange, required this.initialRating, required this.onApply, required this.onReset});

  @override State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _selectedCategories;
  String? _selectedPriceRange;
  int? _selectedRating;

  @override void initState() { super.initState(); _selectedCategories = Set.from(widget.initialCategories); _selectedPriceRange = widget.initialPriceRange; _selectedRating = widget.initialRating; }
  bool get _hasSelection => _selectedCategories.isNotEmpty || _selectedPriceRange != null || _selectedRating != null;
  void _reset() { setState(() { _selectedCategories = {}; _selectedPriceRange = null; _selectedRating = null; }); }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75, minChildSize: 0.5, maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0E4F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [const Text('Filter Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E))), const Spacer(), GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFFF0F2F8), shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Color(0xFF9098B1))))]),
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xFFF0F2F8), thickness: 1),
              Expanded(
                child: ListView(
                  controller: scrollController, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _buildSectionLabel('Kategori'),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: widget.categoryOptions.map((cat) {
                      final bool isSelected = _selectedCategories.contains(cat);
                      return GestureDetector(onTap: () => setState(() { if (isSelected) { _selectedCategories.remove(cat); } else { _selectedCategories.add(cat); } }), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: isSelected ? const Color(0xFF6B7FD7) : Colors.transparent, border: Border.all(color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFFD0D5E8)), borderRadius: BorderRadius.circular(20)), child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF6B7FD7)))));
                    }).toList()),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFF0F2F8), thickness: 1),
                    const SizedBox(height: 16),
                    _buildSectionLabel('Rentang Harga'),
                    const SizedBox(height: 12),
                    Column(children: widget.priceRangeOptions.map((range) {
                      final bool isSelected = _selectedPriceRange == range['label'];
                      return GestureDetector(onTap: () => setState(() { _selectedPriceRange = isSelected ? null : range['label']; }), child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isSelected ? const Color(0xFF6B7FD7).withOpacity(0.08) : const Color(0xFFF8F9FC), border: Border.all(color: isSelected ? const Color(0xFF6B7FD7) : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFFB0B8CC), size: 20), const SizedBox(width: 12), Text(range['label'], style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFF4A4D5E)))])));
                    }).toList()),
                    const SizedBox(height: 4),
                    const Divider(color: Color(0xFFF0F2F8), thickness: 1),
                    const SizedBox(height: 16),
                    _buildSectionLabel('Rating Minimum'),
                    const SizedBox(height: 12),
                    Column(children: List.generate(5, (i) {
                      final int starValue = 5 - i;
                      final bool isSelected = _selectedRating == starValue;
                      return GestureDetector(onTap: () => setState(() { _selectedRating = isSelected ? null : starValue; }), child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isSelected ? const Color(0xFF6B7FD7).withOpacity(0.08) : const Color(0xFFF8F9FC), border: Border.all(color: isSelected ? const Color(0xFF6B7FD7) : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFFB0B8CC), size: 20), const SizedBox(width: 12), Row(children: List.generate(5, (s) => Icon(s < starValue ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFB800), size: 18))), const SizedBox(width: 8), Text('& ke atas', style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFF9098B1), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))])));
                    })),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
                child: Row(children: [Expanded(child: OutlinedButton(onPressed: _reset, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD0D5E8)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Reset', style: TextStyle(color: Color(0xFF9098B1), fontWeight: FontWeight.w600, fontSize: 14)))), const SizedBox(width: 12), Expanded(flex: 2, child: ElevatedButton(onPressed: () { widget.onApply(_selectedCategories, _selectedPriceRange, _selectedRating); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B7FD7), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), child: Text(_hasSelection ? 'Terapkan Filter ($_activeFilterCount)' : 'Terapkan Filter')))]),
              ),
            ],
          ),
        );
      },
    );
  }

  int get _activeFilterCount => (_selectedCategories.isNotEmpty ? 1 : 0) + (_selectedPriceRange != null ? 1 : 0) + (_selectedRating != null ? 1 : 0);
  Widget _buildSectionLabel(String label) { return Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E))); }
}