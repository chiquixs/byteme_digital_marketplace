import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CartPage({super.key, this.onBack});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dummy data ditambahkan 'store'
  bool isSelectAll = false;
  List<Map<String, dynamic>> cartItems = [
    {'id': 1, 'store': 'Official Store', 'name': 'Girls E-Book', 'price': 'Rp 78.000', 'qty': 1, 'selected': false, 'color': Colors.blue.shade100},
    {'id': 2, 'store': 'Official Store', 'name': 'Materials E-Book', 'price': 'Rp 59.000', 'qty': 1, 'selected': false, 'color': Colors.blue.shade300},
    {'id': 3, 'store': 'Official Store', 'name': 'Personal Branding E-Book', 'price': 'Rp 89.000', 'qty': 1, 'selected': false, 'color': Colors.blueGrey},
    {'id': 4, 'store': 'Official Store', 'name': 'Template Canva', 'price': 'Rp 45.000', 'qty': 1, 'selected': false, 'color': Colors.pink.shade100},
    {'id': 5, 'store': 'Official Store', 'name': 'Project Proposal', 'price': 'Rp 120.000', 'qty': 1, 'selected': false, 'color': Colors.brown.shade200},
    {'id': 6, 'store': 'Official Store', 'name': 'Web Design', 'price': 'Rp 150.000', 'qty': 1, 'selected': false, 'color': Colors.blue.shade800},
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F9), // Warna background kebiruan muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // List Produk di dalam Container Putih
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    thickness: 0.2,
                    height: 30,
                  ),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // INI BAGIAN YANG DIREVISI: Nama Store & Ikon
                        Row(
                          children: [
                            const SizedBox(width: 8), // Menyelaraskan posisi dengan checkbox
                            const Icon(Icons.store_mall_directory_outlined, size: 18, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text(
                              item['store'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12), // Jarak antara nama store dan isi produk
                        
                        // Baris isi produk (Checkbox, Gambar, Nama, Harga, Qty)
                        Row(
                          children: [
                            // Checkbox
                            Checkbox(
                              value: item['selected'],
                              onChanged: (value) {
                                setState(() {
                                  item['selected'] = value;
                                  checkSelectAllStatus();
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: const Color(0xFF5A72C6),
                            ),
                            // Gambar Produk (Placeholder)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image, color: Colors.white),
                            ),
                            const SizedBox(width: 12), // Jarak antara gambar dan teks
                            
                            // Nama dan Harga Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4), 
                                  Text(
                                    item['price'],
                                    style: const TextStyle(
                                      color: Color(0xFF5A72C6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Qty Controller
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (item['qty'] > 1) {
                                      setState(() => item['qty']--);
                                    }
                                  },
                                  child: const Text(' - ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F4FD),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item['qty']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => item['qty']++),
                                  child: const Text(' + ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bottom Checkout Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isSelectAll,
                        onChanged: toggleSelectAll,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        activeColor: const Color(0xFF5A72C6),
                      ),
                      const Text('Semua', style: TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Text(
                        'Rp: 10.000',
                        style: TextStyle(
                          color: Color(0xFF5A72C6),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Nanti panggil TransactionController di sini
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}