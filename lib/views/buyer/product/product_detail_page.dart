import 'package:flutter/material.dart';
import '../wishlist/wishlist_page.dart';
import '../../../services/review_service.dart';
import 'package:provider/provider.dart';
import '../../../controller/buyer/cart_controller.dart';
import '../../../controller/buyer/favorit_controller.dart';

// ============================================================
// PRODUCT DETAIL PAGE - Menggunakan FavoritController (API)
// ============================================================

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isSellerView;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.isSellerView = false,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic> _summary = {'rata_rata': 0, 'total': 0};
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = false;
  bool _isAddingToCart = false;

  String get _produkId =>
      widget.product['id']?.toString() ??
      widget.product['produk_id']?.toString() ??
      '';
  
  bool _isDescriptionExpanded = false;

  // Mengambil 1 gambar utama
  String get _mainImage {
    final img =
        widget.product['image'] ??
        widget.product['file_path'] ??
        'assets/images/e-book.jpeg';
    return img.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (_produkId.isEmpty) return;
    setState(() => _isLoadingReviews = true);

    try {
      final data = await ReviewService().getReviewsByProduk(_produkId);
      if (!mounted) return;

      final summary = (data['summary'] as Map<String, dynamic>?) ?? {};
      final List<dynamic> reviewItems =
          (data['reviews'] as List<dynamic>?) ?? [];

      setState(() {
        _summary = {
          'rata_rata':
              summary['rata_rata'] ?? summary['reviews_avg_rating'] ?? 0,
          'total':
              summary['total'] ??
              summary['reviews_count'] ??
              reviewItems.length,
        };
        _reviews = reviewItems;
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingReviews = false);
    }
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF6B7FD7),
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No reviews yet for this product.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ..._reviews.take(3).map((review) {
          final Map<String, dynamic> r = review is Map
              ? Map<String, dynamic>.from(review)
              : {};
          final String reviewerName = r['username'] ?? 'Pembeli ByteMe';
          final int starCount = r['rating'] ?? 5;
          final String commentText = r['komentar'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEF0F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reviewerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    _buildYellowStarRating(starCount.toDouble()),
                  ],
                ),
                if (commentText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    commentText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final String title = product['title'] ?? product['nama_produk'] ?? '';
    final String priceLabel =
        product['priceLabel'] ?? product['price']?.toString() ?? '';

    final dynamic rawInitialRating =
        product['reviews_avg_rating'] ?? product['rating'] ?? 0.0;
    final double initialRating =
        double.tryParse(rawInitialRating.toString()) ?? 0.0;
    final dynamic rawLiveRating = _summary['rata_rata'];
    final double currentRating = (rawLiveRating != null && rawLiveRating != 0)
        ? (double.tryParse(rawLiveRating.toString()) ?? initialRating)
        : initialRating;
    final int currentTotalReviews =
        (_summary['total'] != null && _summary['total'] > 0)
        ? _summary['total']
        : (product['reviews_count'] ?? product['reviews'] ?? 0);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Gunakan Provider untuk mendapatkan status ke-favorit-an secara reaktif
    final favoritController = context.watch<FavoritController>();
    final bool isWishlisted = favoritController.isWishlisted(product);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. BAGIAN GAMBAR
              SliverToBoxAdapter(child: _buildImageSection(context)),

              // 2. BAGIAN DETAIL KONTEN
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // JUDUL & HARGA
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            priceLabel.startsWith('Rp')
                                ? priceLabel
                                : 'Rp $priceLabel',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B7FD7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // RATINGS ROW
                      Row(
                        children: [
                          _buildYellowStarRating(currentRating),
                          const SizedBox(width: 8),
                          Text(
                            '${currentRating.toStringAsFixed(1)} ($currentTotalReviews Reviews)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(thickness: 1, color: Color(0xFFEEF0F7)),
                      const SizedBox(height: 16),

                      // SEKSI ULASAN PEMBELI
                      const Text(
                        'Recent Reviews',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReviewsList(),

                      const SizedBox(height: 16),
                      const Divider(thickness: 1, color: Color(0xFFEEF0F7)),
                      const SizedBox(height: 16),

                      // DESKRIPSI PRODUK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                          if (!widget.isSellerView)
                            IconButton(
                              icon: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: const Color(0xFFFF4D67),
                              ),
                              onPressed: () async {
                                final success = await context
                                    .read<FavoritController>()
                                    .toggleFavorit(product);
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal menyimpan favorit ke server'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['deskripsi'] ??
                            product['description'] ??
                            _dummyDescription,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        maxLines: _isDescriptionExpanded ? null : 3,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(
                          () =>
                              _isDescriptionExpanded = !_isDescriptionExpanded,
                        ),
                        child: Text(
                          _isDescriptionExpanded ? 'Show less' : 'Read more >',
                          style: const TextStyle(
                            color: Color(0xFF6B7FD7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(thickness: 1, color: Color(0xFFEEF0F7)),
                      const SizedBox(height: 20),

                      // SEKSI SELLER
                      _buildSellerInfo(product),

                      // Ruang ekstra di bawah agar konten tidak tertutup tombol Add to Cart
                      SizedBox(height: 100 + bottomPadding),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── TOMBOL ADD TO CART YANG AMAN ──
          if (!widget.isSellerView)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: bottomPadding > 0 ? bottomPadding + 12 : 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7FD7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isAddingToCart
                      ? null
                      : () => _addToCart(context, product),
                  child: _isAddingToCart
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🌟 BAGIAN GAMBAR TUNGGAL (TIDAK ADA SLIDER & PROPORSIONAL) 🌟
  Widget _buildImageSection(BuildContext context) {
    final img = _mainImage;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol Back
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1A1D2E),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Container Gambar Utama
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(
                0xFFE8EAF2,
              ), // Background abu-abu sebagai pelindung/bingkai poster
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: img.startsWith('http')
                  ? Image.network(
                      img,
                      fit: BoxFit.contain, // Mencegah gambar terpotong/zoom
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : Image.asset(
                      img,
                      fit: BoxFit.contain, // Mencegah gambar terpotong/zoom
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF0F2F8),
      child: const Center(
        child: Icon(Icons.image_rounded, color: Color(0xFFB0B8CC), size: 48),
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);

    try {
      final bool added = await context
          .read<KeranjangController>()
          .addToCart(product);

      if (!mounted) return;

      _showCartOverlay(context, product, added);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan ke keranjang'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _showCartOverlay(
    BuildContext context,
    Map<String, dynamic> product,
    bool added,
  ) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) => Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E).withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: added
                          ? const Color(0xFF6B7FD7)
                          : Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      added
                          ? Icons.shopping_cart_outlined
                          : Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    added ? 'Added to Cart!' : 'Already in Cart',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['title'] ?? product['nama_produk'] ?? '',
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
    Future.delayed(
      const Duration(seconds: 2),
      () => overlayEntry.remove(),
    );
  }

  Widget _buildSellerInfo(Map<String, dynamic> product) {
    final dynamic userObj = product['user'];
    final String sellerName = userObj is Map
        ? (userObj['username'] ?? userObj['name'] ?? 'Penjual ByteMe')
        : (product['seller_name'] ??
              product['username'] ??
              product['store_name'] ??
              product['nama_toko'] ??
              'Penjual ByteMe');
    final String sellerAvatar = userObj is Map
        ? (userObj['profile_image'] ?? userObj['avatar'] ?? '').toString()
        : (product['seller_avatar'] ?? product['avatar'] ?? '').toString();

    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFF0F2F8),
          backgroundImage:
              sellerAvatar.isNotEmpty && sellerAvatar.startsWith('http')
              ? NetworkImage(sellerAvatar) as ImageProvider
              : null,
          child: sellerAvatar.isEmpty || !sellerAvatar.startsWith('http')
              ? const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF6B7FD7),
                  size: 24,
                )
              : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sellerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF6B7FD7),
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Official Seller',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYellowStarRating(double rating) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
          size: 16,
          color: Colors.amber,
        ),
      ),
    );
  }

  static const String _dummyDescription =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae.';
}