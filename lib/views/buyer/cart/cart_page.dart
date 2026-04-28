import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../checkout/checkout_page.dart';
import '../../../utils/buyer/cart_manager.dart';

// ============================================================
// CART PAGE - Digital Product Marketplace
// Letakkan file ini di: lib/views/cart/cart_page.dart
// ============================================================

class CartPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CartPage({super.key, this.onBack});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cm = CartManager.instance;
  bool isSelectAll = false;

  // Salinan lokal dari CartManager yang bisa dimodifikasi (selected, dll)
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _syncFromManager();
    _cm.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cm.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    _syncFromManager();
  }

  /// Sync dari CartManager — pertahankan status selected item lama
  void _syncFromManager() {
    final managerItems = _cm.items;
    final Map<String, bool> prevSelected = {
      for (final item in cartItems) item['name'] as String: item['selected'] as bool,
    };

    setState(() {
      cartItems = managerItems.map((item) {
        final name = item['name'] as String;
        return Map<String, dynamic>.from(item)
          ..['selected'] = prevSelected[name] ?? false;
      }).toList();
      _updateSelectAllStatus();
    });
  }

  // ── HELPERS ──

  int _parsePrice(String priceStr) {
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  int _calculateTotal() {
    int total = 0;
    for (final item in cartItems) {
      if (item['selected'] == true) {
        total += _parsePrice(item['price'] as String) * (item['qty'] as int);
      }
    }
    return total;
  }

  String _formatRupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      isSelectAll = value ?? false;
      for (final item in cartItems) {
        item['selected'] = isSelectAll;
      }
    });
  }

  void _updateSelectAllStatus() {
    isSelectAll =
        cartItems.isNotEmpty && cartItems.every((item) => item['selected'] == true);
  }

  void _removeItem(int index) {
    final name = cartItems[index]['name'] as String;
    _cm.removeFromCart(name);
  }

  void _showDeleteConfirmation(BuildContext context, int index, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Remove Item',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to remove "$itemName" from your cart?',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _removeItem(index);
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotal();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2A2A2A), size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              } else {
                widget.onBack?.call();
              }
            },
          ),
        ),
        title: Row(
          children: [
            const Text(
              'My Cart',
              style: TextStyle(
                  color: Color(0xFF2A2A2A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(width: 8),
            if (cartItems.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A72C6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cartItems.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // ── LIST ITEM ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.separated(
                          itemCount: cartItems.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, thickness: 0.2),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return _buildCartItem(context, index, item);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // ── BOTTOM BAR ──
                _buildBottomBar(totalPrice),
              ],
            ),
    );
  }

  // ----------------------------------------------------------
  // EMPTY STATE
  // ----------------------------------------------------------
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF5A72C6).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Color(0xFF5A72C6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Keranjang masih kosong',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan produk dari halaman\nHome atau Explore',
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
  // CART ITEM
  // ----------------------------------------------------------
  Widget _buildCartItem(
      BuildContext context, int index, Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store label
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  size: 16, color: Color(0xFF3D4270)),
              const SizedBox(width: 6),
              Text(
                item['store'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D4270),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),

        // Slidable item
        Slidable(
          key: ValueKey(item['id']),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (ctx) =>
                    _showDeleteConfirmation(ctx, index, item['name'] as String),
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 24),
                    Text('Remove', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: item['selected'] as bool,
                    onChanged: (value) {
                      setState(() {
                        item['selected'] = value;
                        _updateSelectAllStatus();
                      });
                    },
                    activeColor: const Color(0xFF5A72C6),
                  ),
                ),
                const SizedBox(width: 12),

                // Gambar produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: item['image'] != null &&
                            (item['image'] as String).isNotEmpty
                        ? Image.asset(
                            item['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImagePlaceholder(item),
                          )
                        : _buildImagePlaceholder(item),
                  ),
                ),
                const SizedBox(width: 12),

                // Info produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori
                      if (item['category'] != null &&
                          (item['category'] as String).isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A72C6).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5A72C6),
                            ),
                          ),
                        ),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF2A2A2A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['price'] as String,
                        style: const TextStyle(
                          color: Color(0xFF5A72C6),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(Map<String, dynamic> item) {
    const colors = [
      Color(0xFFBBCBF5),
      Color(0xFFD4B8E0),
      Color(0xFFB8D4E0),
      Color(0xFFE0C8B8),
    ];
    final color = colors[(item['id'] as int) % colors.length];
    return Container(
      color: color,
      child: const Icon(Icons.image_outlined, color: Colors.white, size: 24),
    );
  }

  // ----------------------------------------------------------
  // BOTTOM BAR
  // ----------------------------------------------------------
  Widget _buildBottomBar(int totalPrice) {
    final selectedCount =
        cartItems.where((item) => item['selected'] == true).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelectAll,
                  onChanged: _toggleSelectAll,
                  activeColor: const Color(0xFF5A72C6),
                ),
                const Text('Select All',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (selectedCount > 0)
                      Text(
                        '$selectedCount item selected',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9098B1),
                        ),
                      ),
                    Text(
                      _formatRupiah(totalPrice),
                      style: const TextStyle(
                        color: Color(0xFF5A72C6),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A72C6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  final selectedItems = cartItems
                      .where((item) => item['selected'] == true)
                      .toList();

                  if (selectedItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Choose at least one product to checkout!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CheckoutPage(selectedItems: selectedItems),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
