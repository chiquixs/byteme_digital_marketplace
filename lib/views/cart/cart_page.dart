import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import '../checkout/checkout_page.dart'; // Sesuaikan dengan path folder kamu

class CartPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CartPage({super.key, this.onBack});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isSelectAll = false;
  
  List<Map<String, dynamic>> cartItems = [
    {'id': 1, 'store': 'Official Store', 'name': 'Girls E-Book', 'price': 'Rp 78.000', 'qty': 1, 'selected': false, 'color': Colors.blue.shade100},
    {'id': 2, 'store': 'Official Store', 'name': 'Materials E-Book', 'price': 'Rp 59.000', 'qty': 1, 'selected': false, 'color': Colors.blue.shade300},
    {'id': 3, 'store': 'Official Store', 'name': 'Personal Branding E-Book', 'price': 'Rp 89.000', 'qty': 1, 'selected': false, 'color': Colors.blueGrey},
    {'id': 4, 'store': 'Official Store', 'name': 'Template Canva', 'price': 'Rp 45.000', 'qty': 1, 'selected': false, 'color': Colors.pink.shade100},
    {'id': 5, 'store': 'Official Store', 'name': 'Project Proposal', 'price': 'Rp 120.000', 'qty': 1, 'selected': false, 'color': Colors.brown.shade200},
    {'id': 6, 'store': 'Official Store', 'name': 'Web Design', 'price': 'Rp 150.000', 'qty': 1, 'selected': false, 'color': Colors.blue.shade800},
  ];

  // --- LOGIKA PERHITUNGAN DINAMIS ---

  // Fungsi untuk mengubah String harga ke Integer agar bisa dihitung
  int _parsePrice(String priceStr) {
    String cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  // Fungsi menghitung total harga item yang dipilih saja
  int _calculateTotal() {
    int total = 0;
    for (var item in cartItems) {
      if (item['selected'] == true) {
        total += _parsePrice(item['price']) * (item['qty'] as int);
      }
    }
    return total;
  }

  // Fungsi format angka ke Rupiah
  String _formatRupiah(int number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      isSelectAll = value ?? false;
      for (var item in cartItems) {
        item['selected'] = isSelectAll;
      }
    });
  }

  void checkSelectAllStatus() {
    bool allSelected = cartItems.every((item) => item['selected'] == true);
    setState(() {
      isSelectAll = allSelected;
    });
  }

  void _showDeleteConfirmation(BuildContext context, int index, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      "Remove Item",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to remove this item from your cart?",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          cartItems.removeAt(index);
                          checkSelectAllStatus();
                        });
                      },
                      child: const Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung total harga terbaru setiap kali widget dirender ulang
    int totalPrice = _calculateTotal();

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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2A2A2A), size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              } else {
                widget.onBack?.call();
              }
            },
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(color: Color(0xFF2A2A2A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
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
                    separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.2),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF3D4270)),
                                const SizedBox(width: 6),
                                Text(
                                  item['store'],
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3D4270)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
                          Slidable(
                            key: ValueKey(item['id']),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.25,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (context) => _showDeleteConfirmation(context, index, item['name']),
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
                                      value: item['selected'],
                                      onChanged: (value) {
                                        setState(() {
                                          item['selected'] = value;
                                          checkSelectAllStatus();
                                        });
                                      },
                                      activeColor: const Color(0xFF5A72C6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: item['color'],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image_outlined, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2A2A2A)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['price'],
                                          style: const TextStyle(color: Color(0xFF5A72C6), fontWeight: FontWeight.bold, fontSize: 13),
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
                    },
                  ),
                ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isSelectAll,
                        onChanged: toggleSelectAll,
                        activeColor: const Color(0xFF5A72C6),
                      ),
                      const Text('Select All', style: TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      // TOTAL HARGA DINAMIS BERDASARKAN SELEKSI
                      Text(
                        _formatRupiah(totalPrice), 
                        style: const TextStyle(color: Color(0xFF5A72C6), fontWeight: FontWeight.bold, fontSize: 18)
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // FILTER ITEM YANG DIPILIH
                        final selectedItems = cartItems.where((item) => item['selected'] == true).toList();

                        if (selectedItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one item to checkout!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } else {
                          // PINDAH KE HALAMAN CHECKOUT DENGAN DATA
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(selectedItems: selectedItems),
                            ),
                          );
                        }
                      },
                      child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}