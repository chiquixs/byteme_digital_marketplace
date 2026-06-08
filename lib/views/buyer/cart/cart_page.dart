import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../../controller/buyer/cart_controller.dart';
import '../../../../services/checkout_service.dart'; 
import '../../../../controller/buyer/order_controller.dart'; 

class CartPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CartPage({super.key, this.onBack});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isSelectAll = false;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeranjangController>().fetchKeranjang();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _parsePrice(String priceStr) {
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  int _calculateTotal() {
    int total = 0;
    for (final item in cartItems) {
      if (item['selected'] == true) {
        total += _parsePrice(item['price'] as String) * (item['qty'] as int? ?? 1);
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
        cartItems.isNotEmpty &&
        cartItems.every((item) => item['selected'] == true);
  }

  void _removeItem(BuildContext context, int index) {
    final detailId =
        cartItems[index]['detail_keranjang_id'] as String? ?? '';
    if (detailId.isNotEmpty) {
      context.read<KeranjangController>().removeFromCart(detailId);
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int index,
    String itemName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  // ✅ Cancel hanya tutup dialog
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
                  // ✅ Remove yang hapus item
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _removeItem(context, index);
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
    final keranjangController = context.watch<KeranjangController>();

    final Map<String, bool> prevSelected = {
      for (final item in cartItems)
        (item['name'] as String? ?? ''): item['selected'] as bool? ?? false,
    };
    cartItems = keranjangController.items.map((item) {
      return Map<String, dynamic>.from(item)
        ..['selected'] = prevSelected[item['name']] ?? false;
    }).toList();

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
                      fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
      body: keranjangController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5A72C6)),
            )
          : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
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
                    _buildBottomBar(totalPrice),
                  ],
                ),
    );
  }

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
            child: const Icon(Icons.shopping_bag_outlined,
                size: 48, color: Color(0xFF5A72C6)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Keranjang masih kosong',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2A2A2A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan produk dari halaman\nHome atau Explore',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Color(0xFF9098B1), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, int index, Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  size: 16, color: Color(0xFF3D4270)),
              const SizedBox(width: 6),
              Text(
                item['store'] as String? ?? 'Official Store',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D4270)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
        Slidable(
          key: ValueKey(item['detail_keranjang_id'] ?? index),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (_) => _showDeleteConfirmation(
                    context, index, item['name'] as String? ?? ''),
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
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: item['selected'] as bool? ?? false,
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

                // ✅ Support URL dari API dan asset lokal
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: item['image'] != null &&
                            (item['image'] as String).isNotEmpty
                        ? (item['image'] as String).startsWith('http')
                            ? Image.network(
                                item['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildImagePlaceholder(index),
                              )
                            : Image.asset(
                                item['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildImagePlaceholder(index),
                              )
                        : _buildImagePlaceholder(index),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['category'] != null &&
                          (item['category'] as String).isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF5A72C6).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5A72C6)),
                          ),
                        ),
                      Text(
                        item['name'] as String? ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF2A2A2A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['price'] as String? ?? 'Rp 0',
                        style: const TextStyle(
                            color: Color(0xFF5A72C6),
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
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

  Widget _buildImagePlaceholder(int index) {
    const colors = [
      Color(0xFFBBCBF5),
      Color(0xFFD4B8E0),
      Color(0xFFB8D4E0),
      Color(0xFFE0C8B8),
    ];
    final color = colors[index % colors.length];
    return Container(
      color: color,
      child:
          const Icon(Icons.image_outlined, color: Colors.white, size: 24),
    );
  }

  Widget _buildBottomBar(int totalPrice) {
    final selectedCount =
        cartItems.where((item) => item['selected'] == true).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2))
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
                            fontSize: 11, color: Color(0xFF9098B1)),
                      ),
                    Text(
                      _formatRupiah(totalPrice),
                      style: const TextStyle(
                          color: Color(0xFF5A72C6),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
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
                onPressed: () async { 
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
                    return;
                  }

                  
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF5A72C6)),
                    ),
                  );

                  final ids = selectedItems
                      .map((item) => item['detail_keranjang_id'] as String?)
                      .whereType<String>()
                      .toList();

                  if (ids.isEmpty) {
                    Navigator.pop(context); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item tidak valid. Silakan coba lagi.'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Direct API execution
                  final result = await CheckoutService.checkout(detailKeranjangIds: ids);
                  
                  if (!mounted) return;
                  Navigator.pop(context); // Close loading dialog

                  if (!result.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Fetch updated current orders via OrderController
                  context.read<OrderController>().fetchCurrentOrders();

                  //  Open Midtrans checkout URL using url_launcher
                  final url = result.redirectUrl;
                  if (url != null && await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    
                    if (mounted) {
                      // Navigate automatically back to the home screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selesaikan pembayaran di browser. Email akses produk akan dikirim setelah pembayaran dikonfirmasi.'),
                          duration: Duration(seconds: 6),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tidak dapat membuka halaman pembayaran: $url'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
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