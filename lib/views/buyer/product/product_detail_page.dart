import 'package:flutter/material.dart';
import '../wishlist/wishlist_page.dart';
import '../../../services/review_service.dart';
import '../../../utils/buyer/cart_manager.dart';

// ============================================================
// PRODUCT DETAIL PAGE - No Dummy Seller Data Version
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

  String get _produkId => widget.product['id']?.toString() ?? widget.product['produk_id']?.toString() ?? '';
  final PageController _imageController = PageController();
  int _currentImage = 0;
  bool _isWishlisted = false;
  bool _isDescriptionExpanded = false;
  final _wm = WishlistManager.instance;

  List<String> get _images {
    final img = widget.product['image'] ?? widget.product['file_path'] ?? 'assets/images/e-book.jpeg';
    return [img.toString(), img.toString(), img.toString()];
  }

  @override
  void initState() {
    super.initState();
    _isWishlisted = _wm.isWishlisted(widget.product);
    _wm.addListener(_onWishlistChanged);
    _loadReviews();
  }

  void _onWishlistChanged() {
    setState(() => _isWishlisted = _wm.isWishlisted(widget.product));
  }

  Future<void> _loadReviews() async {
    if (_produkId.isEmpty) return;
    setState(() => _isLoadingReviews = true);

    try {
      final data = await ReviewService().getReviewsByProduk(_produkId);
      if (!mounted) return;
      
      final summary = (data['summary'] as Map<String, dynamic>?) ?? {};
      final List<dynamic> reviewItems = (data['reviews'] as List<dynamic>?) ?? [];

      setState(() {
        _summary = {
          'rata_rata': summary['rata_rata'] ?? summary['reviews_avg_rating'] ?? 0,
          'total': summary['total'] ?? summary['reviews_count'] ?? reviewItems.length,
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
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Belum ada teks ulasan untuk produk ini.',
          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ..._reviews.take(3).map((review) {
          final Map<String, dynamic> r = review is Map ? Map<String, dynamic>.from(review) : {};
          final String reviewerName = r['username'] ?? 'Pembeli ByteMe';
          final int starCount = r['rating'] ?? 5;
          final String commentText = r['komentar'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
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
                    Text(reviewerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < starCount ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 12,
                        color: i < starCount ? Colors.amber : Colors.grey.shade300,
                      )),
                    ),
                  ],
                ),
                if (commentText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(commentText, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                ],
              ],
            ),
          );
        }),
      ],
    );
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
    final String title = product['title'] ?? product['nama_produk'] ?? '';
    final String priceLabel = product['priceLabel'] ?? product['price']?.toString() ?? '';

    final dynamic rawInitialRating = product['reviews_avg_rating'] ?? product['rating'] ?? 0.0;
    final double initialRating = double.tryParse(rawInitialRating.toString()) ?? 0.0;
    final dynamic rawLiveRating = _summary['rata_rata'];
    final double currentRating = (rawLiveRating != null && rawLiveRating != 0)
        ? (double.tryParse(rawLiveRating.toString()) ?? initialRating)
        : initialRating;
    final int currentTotalReviews = (_summary['total'] != null && _summary['total'] > 0)
        ? _summary['total']
        : (product['reviews_count'] ?? product['reviews'] ?? 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildImageCarousel()),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. JUDUL & HARGA
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            priceLabel.startsWith('Rp') ? priceLabel : 'Rp $priceLabel',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF6B7FD7)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 2. RATINGS ROW
                      Row(
                        children: [
                          _buildStarRating(currentRating),
                          const SizedBox(width: 8),
                          Text('$currentRating ($currentTotalReviews Ulasan)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(thickness: 1),

                      // 3. SEKSI ULASAN PEMBELI 
                      const Text('Ulasan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      _buildReviewsList(),

                      const SizedBox(height: 20),
                      const Divider(thickness: 1),

                      // 4. DESKRIPSI PRODUK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (!widget.isSellerView)
                            IconButton(
                              icon: Icon(_isWishlisted ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                              onPressed: () => _wm.toggle(product),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['deskripsi'] ?? product['description'] ?? _dummyDescription,
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                        maxLines: _isDescriptionExpanded ? null : 3,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                        child: Text(_isDescriptionExpanded ? 'Show less' : 'Read more >', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),

                      const SizedBox(height: 20),
                      const Divider(thickness: 1),

                      // 5. SEKSI SELLER (SUDAH FIX DINAMIS ASLI DATABASE)
                      _buildSellerInfo(product),
                      
                      const SizedBox(height: 120), 
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ),
          ),
          if (!widget.isSellerView)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B7FD7), padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => _showAddedToCartNotification(context, product),
                  child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddedToCartNotification(BuildContext context, Map<String, dynamic> product) {
    CartManager.instance.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!'), behavior: SnackBarBehavior.floating));
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 250,
      width: double.infinity,
      child: PageView.builder(
        itemCount: _images.length,
        onPageChanged: (i) => setState(() => _currentImage = i),
        itemBuilder: (context, index) {
          final img = _images[index];
          return img.startsWith('http') 
            ? Image.network(img, fit: BoxFit.cover) 
            : Image.asset(img, fit: BoxFit.cover);
        },
      ),
    );
  }

  // ── 🌟 WIDGET SELLER DINAMIS TANPA DATA JEFRI NICHOL 🌟 ──
  Widget _buildSellerInfo(Map<String, dynamic> product) {
    final dynamic userObj = product['user'];
    
    // Logika Sapu Jagat menyaring nama seller asli dari database Supabase kelompok kalian
    final String sellerName = userObj is Map 
        ? (userObj['username'] ?? userObj['name'] ?? 'Penjual ByteMe')
        : (product['seller_name'] ?? product['username'] ?? product['store_name'] ?? product['nama_toko'] ?? 'Penjual ByteMe');
    
    final String sellerAvatar = userObj is Map
        ? (userObj['profile_image'] ?? userObj['avatar'] ?? '').toString()
        : (product['seller_avatar'] ?? product['avatar'] ?? '').toString();

    return Row(
      children: [
        CircleAvatar(
          radius: 25, 
          backgroundColor: const Color(0xFFF0F2F8),
          backgroundImage: sellerAvatar.isNotEmpty && sellerAvatar.startsWith('http')
              ? NetworkImage(sellerAvatar) as ImageProvider
              : null,
          child: sellerAvatar.isEmpty || !sellerAvatar.startsWith('http')
              ? const Icon(Icons.storefront_rounded, color: Color(0xFF6B7FD7), size: 24)
              : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sellerName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1D2E))
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF6B7FD7), size: 14),
                  SizedBox(width: 4),
                  Text('Official Seller', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
        size: 16, color: Colors.amber,
      )),
    );
  }

  static const String _dummyDescription = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vitae.';
}