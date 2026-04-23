import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Jangan lupa import ini!

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

  // Fungsi untuk memunculkan dialog konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context, int index, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan isi
              children: [
                // Ikon Tempat Sampah di atas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.red.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Judul Konfirmasi
                const Text(
                  "Hapus Item?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Pesan Konfirmasi
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                    children: [
                      const TextSpan(text: "Apakah kamu yakin ingin menghapus\n"),
                      TextSpan(
                        text: itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const TextSpan(text: " dari keranjang?"),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                
                // Baris Tombol Action
                Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Jarak antar tombol
                    
                    // Tombol Hapus
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          setState(() {
                            cartItems.removeAt(index); // Hapus item
                            checkSelectAllStatus(); // Update status checkbox
                          });
                          
                          // Notifikasi cantik
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('$itemName dihapus')),
                                ],
                              ),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F9),
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
                    
                    // GANTI DISMISSIBLE DENGAN SLIDABLE
                    return Slidable(
                      key: ValueKey(item['id']),
                      
                      // Mengatur aksi saat digeser dari kanan ke kiri (endActionPane)
                      endActionPane: ActionPane(
                        // Motion menentukan efek animasi saat digeser
                        motion: const ScrollMotion(),
                        
                        // extentRatio mengatur seberapa lebar tombolnya relatif terhadap item
                        extentRatio: 0.25, 
                        
                        children: [
                          // Ini adalah tombol Delete yang muncul saat digeser
                          CustomSlidableAction(
                            onPressed: (context) {
                              // Panggil fungsi konfirmasi saat tombol ditekan
                              _showDeleteConfirmation(context, index, item['name']);
                            },
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline, size: 28),
                                SizedBox(height: 4),
                                Text('Hapus', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Isi konten tetap sama
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
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
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
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
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      onPressed: () {},
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