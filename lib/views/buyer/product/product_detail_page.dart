import 'package:flutter/material.dart';
import '../wishlist/wishlist_page.dart';
import '../../../utils/buyer/cart_manager.dart';

// ============================================================
// PRODUCT DETAIL PAGE - Digital Product Marketplace
// Letakkan file ini di: lib/views/product/product_detail_page.dart
// ============================================================

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _imageController = PageController();
  int _currentImage = 0;
  bool _isWishlisted = false;
  bool _isDescriptionExpanded = false;
  final _wm = WishlistManager.instance;

  // Simulasi multiple gambar — ganti dengan data dari backend
  List<String> get _images {
    final img = widget.product['image'] as String? ?? 'assets/images/e-book.jpeg';
    // TODO(backend): Ganti dengan list gambar dari product model
    return [img, img, img];
  }

  @override
  void initState() {
    super.initState();
    _isWishlisted = _wm.isWishlisted(widget.product);
    _wm.addListener(_onWishlistChanged);
  }

  void _onWishlistChanged() {
    setState(() => _isWishlisted = _wm.isWishlisted(widget.product));
  }

  @override
  void dispose() {
    _wm.removeListener(_onWishlistChanged);
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final double rating = (product['rating'] as num?)?.toDouble() ?? 0.0;
    final String title = product['title'] ?? '';
    final String priceLabel = product['priceLabel'] ?? product['price'] ?? '';
    final String reviews = product['reviews'] ?? '';
    final String category = product['category'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Stack(
        children: [
          // ── SCROLLABLE CONTENT ──
          CustomScrollView(
            slivers: [
              // ── IMAGE CAROUSEL ──
              SliverToBoxAdapter(
                child: _buildImageCarousel(),
              ),

              // ── PRODUCT INFO CARD ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1D2E),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _buildStarRating(rating),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$rating  •  $reviews Terjual',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9098B1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF0F2F8), thickness: 1),
                      const SizedBox(height: 16),

                      // ── DESCRIPTION ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                          // Wishlist button
                          GestureDetector(
                            onTap: () {
                              _wm.toggle(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isWishlisted
                                        ? '$title added to wishlist!'
                                        : '$title removed from wishlist',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: _isWishlisted
                                      ? const Color(0xFFFF4D67)
                                      : const Color(0xFF9098B1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _isWishlisted
                                    ? const Color(0xFFFF4D67).withOpacity(0.1)
                                    : const Color(0xFFF0F2F8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isWishlisted
                                    ? const Color(0xFFFF4D67)
                                    : const Color(0xFFB0B8CC),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Description text
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: _isDescriptionExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          // TODO(backend): Ganti dengan product['description']
                          _dummyDescription,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7380),
                            height: 1.6,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          _dummyDescription,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7380),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(
                          () => _isDescriptionExpanded = !_isDescriptionExpanded,
                        ),
                        child: Text(
                          _isDescriptionExpanded ? 'Show less' : 'Read more >',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7FD7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF0F2F8), thickness: 1),
                      const SizedBox(height: 16),

                      // ── SELLER INFO ──
                      _buildSellerInfo(product),

                      const SizedBox(height: 100), // space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── BACK BUTTON (overlay) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
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
          ),

          // ── ADD TO CART BUTTON (bottom fixed) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                    _showAddedToCartNotification(context, widget.product);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7FD7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ),
        ],
      ),
    );
  }

void _showAddedToCartNotification(BuildContext context, Map<String, dynamic> product) {
  final added = CartManager.instance.addToCart(product);

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E).withOpacity(0.9), // Hitam elegan
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Bulat
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: added ? const Color(0xFF6B7FD7) : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    added ? Icons.shopping_cart_outlined : Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Teks Status
                Text(
                  added ? "Added to Cart!" : "Already in Cart",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Nama Produk
                Text(
                  product['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
}
  // ----------------------------------------------------------
  // IMAGE CAROUSEL
  // ----------------------------------------------------------
  Widget _buildImageCarousel() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _imageController,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _currentImage = i),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.image_rounded,
                          color: Color(0xFFB0B8CC),
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentImage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentImage == i
                      ? const Color(0xFF6B7FD7)
                      : const Color(0xFFD0D5E8),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SELLER INFO
  // ----------------------------------------------------------
  Widget _buildSellerInfo(Map<String, dynamic> product) {
    // TODO(backend): Ganti dengan data seller dari product model
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFD0D5E8),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile.jpeg',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                color: Color(0xFF6B7FD7),
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODO(backend): Ganti dengan product['sellerName']
              const Text(
                'Jefri Nichol',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB800), size: 14),
                  const SizedBox(width: 4),
                  // TODO(backend): Ganti dengan product['sellerRating'] & product['sellerProductCount']
                  const Text(
                    '4.5  |  120 Product',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9098B1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Tombol kunjungi toko seller
        OutlinedButton(
          onPressed: () {
            // TODO: Navigate ke seller profile page
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF6B7FD7)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: const Text(
            'Visit',
            style: TextStyle(
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
  // STAR RATING
  // ----------------------------------------------------------
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded,
              color: Color(0xFFFFB800), size: 14);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              color: Color(0xFFFFB800), size: 14);
        } else {
          return const Icon(Icons.star_outline_rounded,
              color: Color(0xFFD0D5E8), size: 14);
        }
      }),
    );
  }

  // Dummy description — TODO(backend): Ganti dengan product['description']
  static const String _dummyDescription =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae '
      'mauris ipsum. Donec suscipit nunc ut velit imperdiet, in suscipit ipsum '
      'posuere. Fusce quis sapien et mi mattis consequat. Ut ut dictum sem. '
      'Sed vestibulum nibh sapien, a ultricies nibh lobortis non. Integer lobortis '
      'luctus ligula, ut maximus lorem molestie rhoncus. Donec vitae tristique.';
}
