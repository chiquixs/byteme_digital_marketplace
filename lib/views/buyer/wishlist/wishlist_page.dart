import 'package:flutter/material.dart';
import '../product/product_detail_page.dart';
import '../../../utils/buyer/cart_manager.dart';

// ============================================================
// WISHLIST PAGE - Produk yang di-like
// Letakkan file ini di: lib/views/wishlist/wishlist_page.dart
// ============================================================

// ── WISHLIST MANAGER ──
// Singleton sederhana untuk menyimpan state wishlist lintas halaman.
// TODO(backend): Ganti dengan WishlistController + Provider/Riverpod
class WishlistManager {
  WishlistManager._();
  static final WishlistManager instance = WishlistManager._();

  final List<Map<String, dynamic>> _items = [];
  final List<VoidCallback> _listeners = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  bool isWishlisted(Map<String, dynamic> product) {
    return _items.any((p) => p['title'] == product['title']);
  }

  void toggle(Map<String, dynamic> product) {
    if (isWishlisted(product)) {
      _items.removeWhere((p) => p['title'] == product['title']);
    } else {
      _items.add(product);
    }
    for (final cb in _listeners) {
      cb();
    }
  }

  void addListener(VoidCallback cb) => _listeners.add(cb);
  void removeListener(VoidCallback cb) => _listeners.remove(cb);
}

// ── WISHLIST PAGE ──
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _wm = WishlistManager.instance;

  @override
  void initState() {
    super.initState();
    _wm.addListener(_onWishlistChanged);
  }

  @override
  void dispose() {
    _wm.removeListener(_onWishlistChanged);
    super.dispose();
  }

  void _onWishlistChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = _wm.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeader(context, items.length),
            ),
            const SizedBox(height: 20),

            // ── CONTENT ──
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : _buildWishlistGrid(items),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------
  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
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
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1D2E),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wishlist',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2E),
              ),
            ),
            Text(
              '$count produk disimpan',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9098B1),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Badge jumlah item
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4D67).withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: Color(0xFFFF4D67), size: 14),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF4D67),
                ),
              ),
            ],
          ),
        ),
      ],
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D67).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 48,
              color: Color(0xFFFF4D67),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No items in your wishlist',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the ❤️ icon on the product page\nto save your favorite items',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9098B1),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // WISHLIST GRID
  // ----------------------------------------------------------
  Widget _buildWishlistGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.60,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _buildWishlistCard(items[index], context),
    );
  }

  // ----------------------------------------------------------
  // WISHLIST CARD
  // ----------------------------------------------------------
  Widget _buildWishlistCard(Map<String, dynamic> product, BuildContext context) {
    final double rating = (product['rating'] as num?)?.toDouble() ?? 0.0;
    final String priceLabel =
        product['priceLabel'] ?? product['price'] ?? '';

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
            // ── GAMBAR + TOMBOL UNLIKE ──
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      product['image'] ?? 'assets/images/e-book.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF0F2F8),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_rounded,
                                color: Color(0xFFB0B8CC), size: 36),
                            SizedBox(height: 6),
                            Text(
                              'Belum ada\ngambar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFFB0B8CC)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Badge kategori
                    if (product['category'] != null)
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
                    // Tombol unlike (hapus dari wishlist)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          _wm.toggle(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product['title']} dihapus dari wishlist',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF9098B1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFFF4D67),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── INFO PRODUK ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? '',
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
                      _buildStarRating(rating),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['reviews'] ?? '',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF9098B1)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceLabel,
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
                      onPressed: () {
                        final added =
                            CartManager.instance.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? '${product['title']} ditambahkan ke keranjang!'
                                  : '${product['title']} sudah ada di keranjang',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: added
                                ? const Color(0xFF6B7FD7)
                                : const Color(0xFF9098B1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7FD7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
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

  // ----------------------------------------------------------
  // STAR RATING
  // ----------------------------------------------------------
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded,
              color: Color(0xFFFFB800), size: 12);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              color: Color(0xFFFFB800), size: 12);
        } else {
          return const Icon(Icons.star_outline_rounded,
              color: Color(0xFFD0D5E8), size: 12);
        }
      }),
    );
  }
}
