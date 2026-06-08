// ============================================================
// ADD PRODUCT PAGE
// Letakkan file ini di: lib/views/seller/product/add_product.dart
//
// Mengikuti alur Sequence Diagram "Upload Produk Penjual":
// 1. Penjual membuka form → openUploadForm() / displayForm()
// 2. Penjual mengisi & submit → submitProduct(name, desc, price, thumbnail, category)
// 3. Validasi gagal → showValidationError(message) [alt block]
// 4. Validasi sukses → saveThumbnail → save product → successResponse(status:"pending")
// 5. Tampilkan status "Menunggu Review"
// ============================================================

// ── IMPORT DART CORE ──────────────────────────────────────────────────────────
import 'dart:io'; // Digunakan untuk File() — meniru pola di edit_profile_page.dart

// ── IMPORT FLUTTER ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter (meniru register_page.dart)

// ── IMPORT PACKAGE ───────────────────────────────────────────────────────────
import 'package:image_picker/image_picker.dart'; // Meniru pola di user_controller.dart
import 'package:provider/provider.dart'; // Meniru pola di product_page.dart & home_page.dart

// ── IMPORT CONTROLLER ────────────────────────────────────────────────────────
// Meniru pola import controller di product_page.dart
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart';

// ── IMPORT HALAMAN LAIN (Navigasi) ───────────────────────────────────────────
// Meniru pola import navigasi di product_page.dart
import 'package:byteme_digital_marketplace/views/seller/product/product_page.dart';

// ============================================================
// ADD PRODUCT PAGE — StatefulWidget
// Meniru pola class SellerProductPage di product_page.dart
// ============================================================
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage>
    with SingleTickerProviderStateMixin {
  // ── WARNA UTAMA ──────────────────────────────────────────────────────────
  // Meniru konstanta warna yang sama di product_page.dart & seller/home/home_page.dart
  static const Color _accentColor = Color(0xFF3D4270);
  static const Color _primaryBlue = Color(0xFF6B7FD7);
  static const Color _bgColor = Color(0xFFE8E8F0);
  static const Color _errorColor = Color(0xFFFF4D67);

  // ── FORM KEY ─────────────────────────────────────────────────────────────
  // Meniru pola _formKey di register_page.dart
  final _formKey = GlobalKey<FormState>();

  // ── CONTROLLER FORM ──────────────────────────────────────────────────────
  // Meniru pola _nameController, _emailController, dll. di register_page.dart
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // ── STATE THUMBNAIL ──────────────────────────────────────────────────────
  // Meniru pola _profileImagePath di UserController
  // null = belum dipilih, berisi path jika sudah dipilih
  File? _thumbnailFile;

  // ── ImagePicker ──────────────────────────────────────────────────────────
  // Meniru pola final ImagePicker _picker = ImagePicker(); di user_controller.dart
  final ImagePicker _picker = ImagePicker();

  // ── KATEGORI DROPDOWN ────────────────────────────────────────────────────
  // Pilihan kategori produk digital
  final List<String> _categories = [
    'UI Kit',
    'Template',
    'E-Book',
    'Preset',
    'Icon Pack',
    'Font',
    'Plugin',
    'Other',
  ];
  String? _selectedCategory; // null = belum dipilih

  // ── LOADING STATE ────────────────────────────────────────────────────────
  // Meniru pola _isLoading di register_page.dart
  bool _isLoading = false;

  // ── STATUS STATE ─────────────────────────────────────────────────────────
  // Sesuai sequence diagram: setelah submit sukses → status "pending"
  // null = belum submit, 'pending' = sudah submit & menunggu review
  String? _submissionStatus; // null | 'pending'

  // ── ANIMASI ──────────────────────────────────────────────────────────────
  // Meniru pola AnimationController di register_page.dart
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ──────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // Meniru pola initState & dispose di register_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Setup animasi halaman masuk — meniru register_page.dart
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Jalankan animasi saat halaman pertama dibuka
    // → openUploadForm() + displayForm() dalam sequence diagram
    _animController.forward();
  }

  @override
  void dispose() {
    // Selalu dispose controller agar tidak memory leak
    // Meniru pola dispose di register_page.dart
    _animController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PICK THUMBNAIL — saveThumbnail(thumbnail) dalam sequence diagram
  // Meniru pola pickProfileImage() di user_controller.dart
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _pickThumbnail() async {
    // Tampilkan bottom sheet pilihan sumber gambar
    // Meniru pola showModalBottomSheet di product_page.dart
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar — meniru handle bar di product_page.dart _showProductOptions
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E4F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 20),

            // ── Pilih dari Galeri ──
            _buildSourceOptionButton(
              icon: Icons.photo_library_rounded,
              label: 'Select from Gallery',
              color: _primaryBlue,
              onTap: () async {
                Navigator.pop(context); // tutup bottom sheet
                await _doPickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),

            // ── Ambil dari Kamera ──
            _buildSourceOptionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Take a Photo',
              color: _accentColor,
              onTap: () async {
                Navigator.pop(context);
                await _doPickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Eksekusi pengambilan gambar ───────────────────────────────────────────
  // Meniru pola _picker.pickImage() di user_controller.dart
  Future<void> _doPickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,   // batasi ukuran thumbnail produk
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Simpan file ke state → setState agar UI rebuild
        // Meniru pola setState di widget lain
        setState(() {
          _thumbnailFile = File(image.path);
        });
      }
    } catch (e) {
      // Tampilkan error jika gagal (misal: permission ditolak)
      debugPrint('Error picking thumbnail: $e');
      if (mounted) {
        _showErrorSnackbar('Failed to pick thumbnail. Please try again.');
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SUBMIT PRODUCT — submitProduct(name, description, price, thumbnail, category)
  // Sesuai sequence diagram:
  //   → POST /products
  //   → [validasi gagal] errorResponse(422) → showValidationError
  //   → [validasi sukses] saveThumbnail → save → successResponse(status:"pending")
  //   → showStatus("Menunggu Review")
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _submitProduct() async {
    // ── Validasi form (nama, deskripsi, harga, kategori) ──
    // _formKey.currentState!.validate() meniru pola register_page.dart
    final bool formValid = _formKey.currentState!.validate();

    // ── Validasi thumbnail (tidak bisa dari FormField) ──
    if (_thumbnailFile == null) {
      // → errorResponse(message, 422) dalam sequence diagram
      _showErrorSnackbar('Please select a product thumbnail.');
      return;
    }

    if (!formValid) return; // validasi form gagal

    // ── Validasi kategori ──
    if (_selectedCategory == null) {
      _showErrorSnackbar('Please select a product category.');
      return;
    }

    // ── Mulai loading ──
    // Meniru pola setState(() => _isLoading = true) di register_page.dart
    setState(() => _isLoading = true);

    // TODO(backend): Ganti simulasi ini dengan panggilan API nyata:
    //   final response = await ProductService.uploadProduct(
    //     name: _nameController.text.trim(),
    //     description: _descriptionController.text.trim(),
    //     price: double.parse(_priceController.text.trim()),
    //     thumbnail: _thumbnailFile!,
    //     category: _selectedCategory!,
    //   );
    //
    // Sesuai sequence diagram:
    //   POST /products (name, description, price, thumbnail, category)
    //   → StorageService.saveThumbnail(thumbnail) → thumbnailUrl
    //   → ProductRepository.save(..., status:"pending") → productSaved
    //   → successResponse(status:"pending")
    //   → AdminNotificationService.notifyNewProduct(productId, productData)
    await Future.delayed(const Duration(seconds: 2)); // simulasi network call

    if (!mounted) return;

    // ── Setelah sukses: tambahkan produk ke ProductController ──
    // Meniru pola controller.addProduct() yang sudah disiapkan di product_controller.dart
    context.read<ProductController>().addProduct({
      'title': _nameController.text.trim(),
      'price': 'Rp${_priceController.text.trim()}',
      'sales': '0 sales',
      'rating': 0.0,
      'status': 'pending', // ← status:"pending" sesuai sequence diagram
      'image': _thumbnailFile!.path, // path lokal (nanti diganti thumbnailUrl dari backend)
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
    });

    setState(() {
      _isLoading = false;
      // → showStatus("Menunggu Review") dalam sequence diagram
      _submissionStatus = 'pending';
    });
  }

  // ── Helper: tampilkan error SnackBar ─────────────────────────────────────
  // Meniru pola ScaffoldMessenger.of(context).showSnackBar di product_page.dart
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _submissionStatus == 'pending'
                      // ── Jika sudah submit → tampilkan halaman "Menunggu Review" ──
                      // → showStatus("Menunggu Review") dalam sequence diagram
                      ? _buildPendingStatusView()
                      // ── Jika belum submit → tampilkan form ──
                      : _buildForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER
  // Meniru pola _buildHeader di product_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          // Tombol back → kembali ke SellerProductPage
          // Meniru pola GestureDetector + Navigator.pop/pushReplacement di product_page.dart
          GestureDetector(
            onTap: () {
              // Jika sedang loading, jangan izinkan kembali
              if (_isLoading) return;
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _accentColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Add Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _accentColor,
            ),
          ),
          const Spacer(),
          // Badge status form — meniru pola badge di product_page.dart
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'New Product',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FORM — displayForm() dalam sequence diagram
  // Meniru pola Form + SingleChildScrollView di register_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. THUMBNAIL PICKER ──────────────────────────────────────
            // → saveThumbnail(thumbnail) dalam sequence diagram
            _buildSectionLabel('Product Thumbnail'),
            const SizedBox(height: 8),
            _buildThumbnailPicker(),
            const SizedBox(height: 20),

            // ── 2. NAMA PRODUK ───────────────────────────────────────────
            // → parameter "name" di submitProduct(name, ...)
            _buildSectionLabel('Product Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Example: Mobile App UI Kit',
              icon: Icons.label_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Product name cannot be empty';
                }
                if (v.trim().length < 3) {
                  return 'Product name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── 3. DESKRIPSI ─────────────────────────────────────────────
            // → parameter "description" di submitProduct(...)
            _buildSectionLabel('Product Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Explain your digital product in a nutshell...',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description cannot be empty';
                }
                if (v.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── 4. HARGA ─────────────────────────────────────────────────
            // → parameter "price" di submitProduct(...)
            _buildSectionLabel('Price'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _priceController,
              hint: 'Example: 150.000',
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              // Hanya izinkan angka — meniru pola inputFormatters di register_page.dart
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Price cannot be empty';
                }
                final price = int.tryParse(v.trim());
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── 5. KATEGORI ──────────────────────────────────────────────
            // → parameter "category" di submitProduct(...)
            _buildSectionLabel('Category'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 32),

            // ── 6. TOMBOL SUBMIT ─────────────────────────────────────────
            // → submitProduct(name, description, price, thumbnail, category)
            // → POST /products dalam sequence diagram
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // THUMBNAIL PICKER WIDGET
  // Meniru pola FileImage(File(...)) di edit_profile_page.dart
  // dan pola GestureDetector image di berbagai halaman
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildThumbnailPicker() {
    return GestureDetector(
      onTap: _pickThumbnail, // panggil _pickThumbnail saat di-tap
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Garis biru jika sudah ada gambar, abu-abu jika belum
            color: _thumbnailFile != null
                ? _primaryBlue.withOpacity(0.5)
                : const Color(0xFFE0E4F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _thumbnailFile != null
            // ── Jika sudah ada thumbnail → tampilkan gambar ──
            // Meniru pola FileImage(File(path)) di edit_profile_page.dart
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar thumbnail yang dipilih
                    Image.file(
                      _thumbnailFile!,
                      fit: BoxFit.cover,
                    ),
                    // Overlay gelap + ikon edit di pojok kanan bawah
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            // ── Jika belum ada thumbnail → tampilkan placeholder ──
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: _primaryBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to upload a thumbnail',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG — maks 5MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DROPDOWN KATEGORI
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Meniru warna border enabledBorder di register_page.dart
          color: const Color(0xFFE8ECF4),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hint: Row(
            children: [
              const Icon(
                Icons.category_outlined,
                color: Color(0xFF9098B1),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Select product category',
                style: TextStyle(
                  color: const Color(0xFFB0B8CC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF9098B1),
          ),
          borderRadius: BorderRadius.circular(12),
          onChanged: (String? value) {
            setState(() => _selectedCategory = value);
          },
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1D2E),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TOMBOL SUBMIT
  // Meniru pola tombol utama di register_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        // Disable saat loading — meniru pola di register_page.dart
        onPressed: _isLoading ? null : _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryBlue.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            // Indikator loading — meniru pola di register_page.dart
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Submit Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PENDING STATUS VIEW
  // → showStatus("Menunggu Review") dalam sequence diagram
  // Ditampilkan setelah successResponse(status:"pending") diterima
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPendingStatusView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ikon status menunggu ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD), // kuning soft
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 48,
                color: Color(0xFFF59E0B), // warna kuning/amber
              ),
            ),
            const SizedBox(height: 24),

            // ── Judul ──
            const Text(
              'Waiting for Review',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // ── Deskripsi ──
            Text(
              'Your product has been submitted and is currently waiting '
              'for review by the admin. You will receive a notification '
              'once the product is approved or rejected.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Badge Status "Pending" ──
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Status: Pending Review',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Tombol kembali ke halaman produk ──
            // Meniru pola Navigator.pushReplacement di product_page.dart
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // kembali ke SellerProductPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'View Product List',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Tombol tambah produk lagi ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  // Reset semua state untuk tambah produk baru
                  setState(() {
                    _submissionStatus = null;
                    _thumbnailFile = null;
                    _selectedCategory = null;
                    _nameController.clear();
                    _descriptionController.clear();
                    _priceController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  side: const BorderSide(color: _primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add Product Again',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SECTION LABEL
  // Meniru _buildSectionLabel di register_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1D2E),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TEXT FIELD REUSABLE
  // Meniru _buildTextField di register_page.dart — persis sama agar konsisten
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      // Meniru style teks di register_page.dart
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1D2E),
      ),
      // Meniru InputDecoration lengkap di register_page.dart
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFB0B8CC),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9098B1), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8ECF4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B7FD7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          color: _errorColor,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPER: Tombol opsi di bottom sheet (pilih sumber gambar)
  // Meniru pola _buildOptionButton di product_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSourceOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}