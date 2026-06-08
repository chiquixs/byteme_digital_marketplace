// ============================================================
// EDIT PRODUCT PAGE
// Letakkan file ini di: lib/views/seller/product/edit_product.dart
//
// Halaman ini dibuka dari titik tiga (⋯) di product_page.dart
// ketika seller menekan "Edit Product".
//
// Menerima data produk yang sudah ada via constructor parameter
// dan mengisi form dengan data tersebut untuk diedit.
// ============================================================

// ── IMPORT DART CORE ──────────────────────────────────────────────────────────
import 'dart:io'; // Untuk File() — meniru pola di edit_profile_page.dart

// ── IMPORT FLUTTER ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter

// ── IMPORT PACKAGE ───────────────────────────────────────────────────────────
import 'package:image_picker/image_picker.dart'; // Meniru pola di user_controller.dart
import 'package:provider/provider.dart'; // Meniru pola di product_page.dart

// ── IMPORT CONTROLLER ────────────────────────────────────────────────────────
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart';

// ============================================================
// EDIT PRODUCT PAGE — StatefulWidget
// Meniru pola class AddProductPage di add_product.dart
// ============================================================
class EditProductPage extends StatefulWidget {
  // Menerima data produk yang akan diedit dari product_page.dart
  // Meniru pola parameter constructor di berbagai halaman project ini
  final Map<String, dynamic> product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage>
    with SingleTickerProviderStateMixin {
  // ── WARNA UTAMA ──────────────────────────────────────────────────────────
  // Sama persis dengan product_page.dart & add_product.dart
  static const Color _accentColor = Color(0xFF3D4270);
  static const Color _primaryBlue = Color(0xFF6B7FD7);
  static const Color _bgColor = Color(0xFFE8E8F0);
  static const Color _errorColor = Color(0xFFFF4D67);

  // ── FORM KEY ─────────────────────────────────────────────────────────────
  // Meniru pola _formKey di register_page.dart & add_product.dart
  final _formKey = GlobalKey<FormState>();

  // ── CONTROLLER FORM ──────────────────────────────────────────────────────
  // Meniru pola TextEditingController di register_page.dart
  // Di-inisialisasi di initState() dengan data produk yang diterima
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  // ── STATE THUMBNAIL ──────────────────────────────────────────────────────
  // null = gunakan gambar lama (dari product['image'])
  // berisi File jika user memilih gambar baru
  File? _newThumbnailFile;

  // ── ImagePicker ──────────────────────────────────────────────────────────
  // Meniru pola final ImagePicker _picker = ImagePicker(); di user_controller.dart
  final ImagePicker _picker = ImagePicker();

  // ── KATEGORI DROPDOWN ────────────────────────────────────────────────────
  // Meniru pola _categories & _selectedCategory di add_product.dart
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
  String? _selectedCategory;

  // ── LOADING STATE ────────────────────────────────────────────────────────
  // Meniru pola _isLoading di register_page.dart & add_product.dart
  bool _isLoading = false;

  // ── ANIMASI ──────────────────────────────────────────────────────────────
  // Meniru pola AnimationController di register_page.dart & add_product.dart
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ──────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // Meniru pola initState di register_page.dart
  // Bedanya: controller diisi dengan data produk yang sudah ada (pre-filled)
  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // ── Pre-fill form dengan data produk yang diterima ──
    // Meniru pola late TextEditingController + data dari controller di edit_profile_page.dart
    _nameController = TextEditingController(
      text: widget.product['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product['description'] ?? '',
    );

    // Harga: bersihkan simbol '$' agar hanya angka yang muncul di form
    // Misal product['price'] = '$29' → ambil hanya '29'
    final rawPrice = (widget.product['price'] as String? ?? '')
        .replaceAll(RegExp(r'[^\d]'), '');
    _priceController = TextEditingController(text: rawPrice);

    // Kategori: cocokkan dengan list _categories
    // Jika ada di list → pre-select, jika tidak → null (user pilih manual)
    final cat = widget.product['category'] as String?;
    _selectedCategory = _categories.contains(cat) ? cat : null;

    // ── Setup animasi halaman masuk ──
    // Meniru pola di add_product.dart & register_page.dart
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

    _animController.forward();
  }

  @override
  void dispose() {
    // Selalu dispose semua controller — meniru pola di register_page.dart
    _animController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PICK THUMBNAIL BARU
  // Meniru pola _pickThumbnail di add_product.dart
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _pickThumbnail() async {
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
            // Handle bar — meniru pola di product_page.dart
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
              'Replace Thumbnail',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildSourceOptionButton(
              icon: Icons.photo_library_rounded,
              label: 'Select from Galery',
              color: _primaryBlue,
              onTap: () async {
                Navigator.pop(context);
                await _doPickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
            _buildSourceOptionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Take a picture',
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

  // Eksekusi pengambilan gambar — meniru pola _doPickImage di add_product.dart
  Future<void> _doPickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _newThumbnailFile = File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking thumbnail: $e');
      if (mounted) _showErrorSnackbar('Failed to take a photo. Please try again.');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SAVE / UPDATE PRODUK
  // Meniru pola _submitProduct di add_product.dart
  // Bedanya: memanggil controller.updateProduct() bukan addProduct()
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _saveProduct() async {
    // Validasi form
    final bool formValid = _formKey.currentState!.validate();
    if (!formValid) return;

    // Validasi kategori
    if (_selectedCategory == null) {
      _showErrorSnackbar('Select a product category.');
      return;
    }

    setState(() => _isLoading = true);

    // TODO(backend): Ganti simulasi ini dengan panggilan API:
    //   await ProductService.updateProduct(
    //     id: widget.product['id'],
    //     name: _nameController.text.trim(),
    //     description: _descriptionController.text.trim(),
    //     price: double.parse(_priceController.text.trim()),
    //     thumbnail: _newThumbnailFile, // null = tidak ganti thumbnail
    //     category: _selectedCategory!,
    //   );
    await Future.delayed(const Duration(seconds: 2)); // simulasi network

    if (!mounted) return;

    // ── Update data di ProductController ──
    // Memanggil controller.updateProduct() yang sudah disiapkan di product_controller.dart
    context.read<ProductController>().updateProduct(
      widget.product['title'], // cari produk berdasarkan title lama
      {
        'title': _nameController.text.trim(),
        'price': 'Rp${_priceController.text.trim()}',
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        // Jika user pilih gambar baru → pakai path baru, jika tidak → pertahankan lama
        'image': _newThumbnailFile?.path ?? widget.product['image'],
        // Pertahankan data lain yang tidak diedit
        'sales': widget.product['sales'],
        'rating': widget.product['rating'],
        'status': widget.product['status'],
      },
    );

    setState(() => _isLoading = false);

    // Tampilkan snackbar sukses — meniru pola di product_page.dart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('The product has been successfully updated'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Kembali ke halaman sebelumnya (product_page.dart)
    // Meniru pola Navigator.pop di berbagai halaman
    if (mounted) Navigator.pop(context);
  }

  // ── Helper: tampilkan error SnackBar ─────────────────────────────────────
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
                Expanded(child: _buildForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER
  // Meniru pola _buildHeader di add_product.dart & product_page.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_isLoading) return; // jangan kembali saat loading
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
            'Edit Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _accentColor,
            ),
          ),
          const Spacer(),
          // Badge nama produk yang sedang diedit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Edit',
              style: const TextStyle(
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
  // FORM — pre-filled dengan data produk yang diterima
  // Meniru pola _buildForm di add_product.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. THUMBNAIL ──────────────────────────────────────────────
            _buildSectionLabel('Thumbnail Product'),
            const SizedBox(height: 8),
            _buildThumbnailPicker(),
            const SizedBox(height: 20),

            // ── 2. NAMA PRODUK ────────────────────────────────────────────
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

            // ── 3. DESKRIPSI ──────────────────────────────────────────────
            _buildSectionLabel('Product Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Explain your digital product briefly...',
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

            // ── 4. HARGA ──────────────────────────────────────────────────
            _buildSectionLabel('Price'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _priceController,
              hint: 'Example: 150.000',
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'The price field cannot be left blank';
                }
                final price = int.tryParse(v.trim());
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── 5. KATEGORI ───────────────────────────────────────────────
            _buildSectionLabel('Category'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 32),

            // ── 6. TOMBOL SIMPAN ──────────────────────────────────────────
            _buildSaveButton(),

            const SizedBox(height: 12),

            // ── 7. TOMBOL BATAL ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accentColor,
                  side: const BorderSide(color: Color(0xFFD0D5E8), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // THUMBNAIL PICKER WIDGET
  // Meniru pola _buildThumbnailPicker di add_product.dart
  // Bedanya: bisa menampilkan gambar lama (asset) atau baru (File)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildThumbnailPicker() {
    // Tentukan apakah ada gambar yang akan ditampilkan
    final bool hasNewImage = _newThumbnailFile != null;
    final String? oldImagePath = widget.product['image'] as String?;
    final bool hasOldImage = oldImagePath != null && oldImagePath.isNotEmpty;

    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (hasNewImage || hasOldImage)
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Tampilkan gambar baru (File) jika ada ──
              if (hasNewImage)
                Image.file(_newThumbnailFile!, fit: BoxFit.cover)

              // ── Tampilkan gambar lama (asset/path) jika ada ──
              else if (hasOldImage)
                Image.asset(
                  oldImagePath!,
                  fit: BoxFit.cover,
                  // Meniru pola errorBuilder di product_page.dart
                  errorBuilder: (context, error, stackTrace) {
                    return _buildThumbnailPlaceholder();
                  },
                )

              // ── Placeholder jika tidak ada gambar ──
              else
                _buildThumbnailPlaceholder(),

              // ── Overlay tombol ganti thumbnail (selalu tampil di atas gambar) ──
              if (hasNewImage || hasOldImage)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Replace',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder thumbnail kosong
  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: Colors.white,
      child: Column(
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DROPDOWN KATEGORI
  // Meniru pola _buildCategoryDropdown di add_product.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF4), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hint: Row(
            children: [
              const Icon(Icons.category_outlined,
                  color: Color(0xFF9098B1), size: 20),
              const SizedBox(width: 12),
              Text(
                'Select product category',
                style: TextStyle(color: const Color(0xFFB0B8CC), fontSize: 14),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9098B1)),
          borderRadius: BorderRadius.circular(12),
          onChanged: (String? value) {
            setState(() => _selectedCategory = value);
          },
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D2E)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TOMBOL SIMPAN
  // Meniru pola _buildSubmitButton di add_product.dart
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProduct,
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
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SECTION LABEL
  // Meniru _buildSectionLabel di register_page.dart & add_product.dart
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
  // Meniru _buildTextField di register_page.dart & add_product.dart — identik
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
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B8CC), fontSize: 14),
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
        errorStyle: const TextStyle(fontSize: 11, color: _errorColor),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPER: Tombol opsi di bottom sheet (pilih sumber gambar)
  // Meniru pola _buildSourceOptionButton di add_product.dart
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
                  fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}