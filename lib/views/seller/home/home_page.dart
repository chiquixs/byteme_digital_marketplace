import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../product/product_page.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/views/seller/profile/seller_profile_page.dart';
import 'package:byteme_digital_marketplace/views/seller/earnings/earnings_page.dart';
import 'package:byteme_digital_marketplace/views/seller/order/seller_order_page.dart';
import 'package:byteme_digital_marketplace/views/buyer/product/product_detail_page.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _pages => [
        SellerHomeContent(
          onMorePressed: () => _switchTab(1),
          onWithdrawPressed: () => _switchTab(3),
        ),
        SellerProductPage(onBackPressed: () => _switchTab(0)),
        SellerOrderPage(onBackPressed: () => _switchTab(0)),
        EarningsPage(onBackPressed: () => _switchTab(0)),
        const SellerProfilePage(),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.grid_view_rounded, 'Product'),
              _buildNavItem(2, Icons.shopping_bag_outlined, 'My Order'),
              _buildNavItem(3, Icons.auto_graph_rounded, 'Earnings'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B7FD7).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF6B7FD7)
                    : const Color(0xFFB0B8CC),
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF6B7FD7)
                        : const Color(0xFFB0B8CC))),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DASHBOARD CONTENT
// ---------------------------------------------------------------------------
class SellerHomeContent extends StatefulWidget {
  final VoidCallback onMorePressed;
  final VoidCallback onWithdrawPressed;

  const SellerHomeContent({
    super.key,
    required this.onMorePressed,
    required this.onWithdrawPressed,
  });

  @override
  State<SellerHomeContent> createState() => _SellerHomeContentState();
}

class _SellerHomeContentState extends State<SellerHomeContent> {
  static const Color accentColor = Color(0xFF3D4270);
  static const Color primaryBlue = Color(0xFF6B7FD7);

  bool _isLoading = true;
  String? _errorMessage;

  int _totalSales = 0;
  int _totalProducts = 0;
  double _totalBalance = 0;
  double _availableWithdraw = 0;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productRes = await ApiService.get('/seller/products');
      final earningsRes = await ApiService.get('/seller/earnings');

      if (!mounted) return;

      if (productRes.statusCode == 200) {
        final productData = jsonDecode(productRes.body);
        final List rawProducts =
            productData['data'] ?? productData['products'] ?? [];
        setState(() {
          _products = rawProducts
              .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e))
              .toList();
          _totalProducts = _products.length;
        });
      }

      if (earningsRes.statusCode == 200) {
        final earningsData = jsonDecode(earningsRes.body);
        final data = earningsData['data'] ?? earningsData;
        setState(() {
          _totalSales = (data['total_sales'] as num?)?.toInt() ?? 0;
          _totalBalance =
              (data['total_balance'] as num?)?.toDouble() ?? 0.0;
          _availableWithdraw =
              (data['available_withdraw'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Gagal memuat data. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(double amount) {
    if (amount == 0) return 'Rp 0';
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: accentColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome 😊',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        userController.displayName.isEmpty
                            ? userController.username
                            : userController.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: accentColor, size: 22),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Vendor Dashboard',
                  style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 16),

              // Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 20),

              // Stat Cards
              Row(
                children: [
                  _buildStatCard(
                    'Total Sales',
                    _isLoading ? null : _totalSales.toString(),
                    Icons.shopping_bag_outlined,
                    'Belum ada penjualan',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Total Product',
                    _isLoading ? null : _totalProducts.toString(),
                    Icons.inventory_2_outlined,
                    'Belum ada produk',
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Discover Product header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discover Product',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: accentColor)),
                  GestureDetector(
                    onTap: widget.onMorePressed,
                    child: const Text('more >',
                        style:
                            TextStyle(color: primaryBlue, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Grid
              _buildProductSection(),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: _fetchDashboardData,
                    icon: const Icon(Icons.refresh, color: primaryBlue),
                    label: const Text('Coba lagi',
                        style: TextStyle(color: primaryBlue)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Balance Card ─────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6B7FD7), Color(0xFF8B90C1)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B7FD7).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Balance',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
              Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white.withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 6),
          _isLoading
              ? _shimmerBox(width: 140, height: 36)
              : Text(
                  _totalBalance == 0
                      ? 'Rp 0'
                      : _formatRupiah(_totalBalance),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available for Withdraw',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  _isLoading
                      ? _shimmerBox(width: 90, height: 20)
                      : _availableWithdraw == 0
                          ? const Text('Belum ada saldo',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic))
                          : Text(
                              _formatRupiah(_availableWithdraw),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.onWithdrawPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3D4270),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Withdraw',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stat Card ────────────────────────────────────────────────────────────
  Widget _buildStatCard(
      String label, String? value, IconData icon, String emptyText) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
                Icon(icon, size: 16, color: primaryBlue),
              ],
            ),
            const SizedBox(height: 8),
            value == null
                ? _shimmerBox(width: 50, height: 22)
                : value == '0'
                    ? Text(emptyText,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontStyle: FontStyle.italic))
                    : Text(value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  // ── Product Section ──────────────────────────────────────────────────────
  Widget _buildProductSection() {
    if (_isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75),
        itemBuilder: (_, __) => _buildSkeletonCard(),
      );
    }

    if (_errorMessage != null && _products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.wifi_off_rounded,
        message: _errorMessage!,
        sub: 'Tarik ke bawah untuk memuat ulang',
      );
    }

    if (_products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada produk',
        sub: 'Tambahkan produk pertamamu di tab Product',
      );
    }

    final preview = _products.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: preview.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75),
      itemBuilder: (context, index) =>
          _buildProductCard(context, preview[index]),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Map<String, dynamic> product) {
    final String title = product['nama_produk'] ??
        product['title'] ??
        product['name'] ??
        'Produk';
    final dynamic rawPrice =
        product['harga'] ?? product['price'] ?? 0;
    final double price = (rawPrice as num).toDouble();
    final double rating =
        (product['rating'] as num?)?.toDouble() ?? 0.0;
    final String? imageUrl =
        product['gambar'] ?? product['image_url'] ?? product['image'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: {
                ...product,
                'title': title,
                'price': price,
                'priceLabel': _formatRupiah(price),
                'rating': rating,
                'image': imageUrl ?? '',
              },
              isSellerView: true,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        rating > 0
                            ? rating.toStringAsFixed(1)
                            : 'Belum ada rating',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price > 0 ? _formatRupiah(price) : 'Gratis',
                    style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEEF0FB),
      child: const Icon(Icons.image_outlined,
          color: primaryBlue, size: 36),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String sub,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFFB0B8CC)),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: accentColor)),
          const SizedBox(height: 6),
          Text(sub,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(
                    height: 12,
                    width: 80,
                    color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6)),
    );
  }
}