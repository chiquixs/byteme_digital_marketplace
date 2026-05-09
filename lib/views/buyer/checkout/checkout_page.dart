import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/views/buyer/payment/unpaid_order.dart'; // Import halaman timer
import 'payment_selection_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:byteme_digital_marketplace/services/checkout_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  const CheckoutPage({super.key, required this.selectedItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Awalnya null agar user wajib memilih
  String? selectedPaymentMethod; 
  final int serviceFeePerItem = 2000;

  int _parsePrice(String priceStr) {
    String cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  int _calculateSubtotal() {
    int total = 0;
    for (var item in widget.selectedItems) {
      int price = _parsePrice(item['price']);
      int qty = item['qty'] ?? 1;
      total += (price * qty);
    }
    return total;
  }

  String _formatCurrency(int number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  // Fungsi untuk pindah ke halaman "See All" dan mengambil hasilnya
  Future<void> _navigateToPaymentSelection(int total) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSelectionPage(totalAmount: total),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        selectedPaymentMethod = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    int subtotal = _calculateSubtotal();
    int totalServiceFee = serviceFeePerItem * widget.selectedItems.length;
    int grandTotal = subtotal + totalServiceFee;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileSection(userController),
            const SizedBox(height: 16),
            _buildOrderListSection(),
            const SizedBox(height: 16),
            _buildPaymentMethodSection(grandTotal), // Pilihan pembayaran ada di sini
            const SizedBox(height: 16),
            _buildPaymentDetailsSection(subtotal, totalServiceFee, grandTotal),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context, grandTotal),
    );
  }

  // --- UI COMPONENTS ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildProfileSection(UserController user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.account_circle_outlined, size: 40, color: Color(0xFF3D4270)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(user.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Text('Email: ${user.email}', style: const TextStyle(color: Colors.black87, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildOrderListSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(children: [Icon(Icons.list_alt_rounded, size: 20), SizedBox(width: 8), Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold))]),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.selectedItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = widget.selectedItems[index];
              return ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.file_present_rounded, color: Colors.white, size: 20),
                ),
                title: Text(item['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text(item['price'], style: const TextStyle(fontSize: 12, color: Color(0xFF5A72C6), fontWeight: FontWeight.bold)),
                trailing: Text('${item['qty'] ?? 1}x'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              GestureDetector(
                onTap: () => _navigateToPaymentSelection(total),
                child: const Text('See All >', style: TextStyle(color: Color(0xFF5A72C6), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // OPSI 1: QRIS
          _buildPaymentOption('QRIS', Icons.qr_code_scanner),
          const SizedBox(height: 12),
          // OPSI 2: Transfer Bank
          _buildPaymentOption('Bank Transfer', Icons.account_balance_outlined),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon) {
    bool isSelected = selectedPaymentMethod == name;
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = name),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? const Color(0xFF3D4270) : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsSection(int sub, int fee, int grand) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _detailRow('Subtotal', _formatCurrency(sub)),
          _detailRow('Service Fee', _formatCurrency(fee)),
          const Divider(),
          _detailRow('Total Payment', _formatCurrency(grand), isBold: true),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? const Color(0xFF3D4270) : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D4270),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => _placeOrder(context),
            child: const Text(
              'Place Order',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  bool _isPlacingOrder = false;

  Future<void> _placeOrder(BuildContext context) async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method first!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    // Collect the real backend IDs.
    // Each cart item stored by KeranjangController has 'detail_keranjang_id'.
    final ids = widget.selectedItems
        .map((item) => item['detail_keranjang_id'] as String?)
        .whereType<String>()
        .toList();

    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item tidak valid. Silakan kembali ke keranjang.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isPlacingOrder = false);
      return;
    }

    final result = await CheckoutService.checkout(detailKeranjangIds: ids);
    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

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

    // Open Midtrans payment page
    final url = result.redirectUrl;
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      // Navigate back to home — payment status will be updated via backend webhook
      if (mounted) {
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
  }
}