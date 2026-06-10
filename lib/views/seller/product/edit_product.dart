// ============================================================
// EDIT PRODUCT PAGE
// Letakkan file ini di: lib/views/seller/product/edit_product.dart
// ============================================================

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart';
import 'package:byteme_digital_marketplace/utils/notif_helper.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage>
    with SingleTickerProviderStateMixin {
  static const Color _accentColor = Color(0xFF3D4270);
  static const Color _primaryBlue = Color(0xFF6B7FD7);
  static const Color _bgColor = Color(0xFFE8E8F0);
  static const Color _errorColor = Color(0xFFFF4D67);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  File? _newThumbnailFile;
  final ImagePicker _picker = ImagePicker();

  // 🌟 Kategori Dinamis dari API
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = false;
  String? _selectedCategory; // Akan menyimpan ID kategori

  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // ── Pre-fill form dengan data produk yang diterima dari Laravel ──
    _nameController = TextEditingController(
      text: widget.product['nama_produk'] ?? widget.product['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product['deskripsi'] ?? widget.product['description'] ?? '',
    );

    final rawPrice = (widget.product['harga'] ?? widget.product['price'] ?? '').toString().replaceAll(RegExp(r'[^\d]'), '');
    _priceController = TextEditingController(text: rawPrice);

    // Ambil kategori ID bawaan (jika ada) untuk di pre-select
    if (widget.product['kategori_id'] != null) {
      _selectedCategory = widget.product['kategori_id'].toString();
    } else if (widget.product['kategori'] is Map) {
      _selectedCategory = widget.product['kategori']['id']?.toString();
    }

    // Ambil data kategori asli dari API
    _fetchCategories();

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

  // 🌟 Fungsi mengambil kategori dari Backend (Sama dengan Add Product)
  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final response = await ApiService.get('/kategori');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _categories = data.map((e) => Map<String, dynamic>.from(e)).toList();
          
          // Jika tidak ada kategori bawaan produk, biarkan null
          // Tapi pastikan ID lama masih ada di daftar baru, jika tidak, reset null
          if (_selectedCategory != null) {
            final exists = _categories.any((c) => c['id'].toString() == _selectedCategory);
            if (!exists) _selectedCategory = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetch kategori: $e');
    }
    if (mounted) setState(() => _isLoadingCategories = false);
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

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

  Future<void> _saveProduct() async {
    final bool formValid = _formKey.currentState!.validate();
    if (!formValid) return;

    if (_selectedCategory == null) {
      _showErrorSnackbar('Select a product category.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productId = widget.product['produk_id'] ?? widget.product['id'];
      
      final response = await ApiService.postMultipart(
        '/produk/$productId', 
        {
          // 🌟 BARIS '_method': 'PUT' DIHAPUS DARI SINI
          'nama_produk': _nameController.text.trim(),
          'deskripsi': _descriptionController.text.trim(),
          'harga': _priceController.text.trim(),
          'kategori_ids[]': _selectedCategory!, 
        },
        filePaths: _newThumbnailFile != null ? {'file': _newThumbnailFile!.path} : null,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh product list di controller
        context.read<ProductController>().fetchMyProducts();

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('The product has been successfully updated'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        if (mounted) Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to update product');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Connection error.');
        setState(() => _isLoading = false);
      }
    }
  }

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
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
            'Edit Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _accentColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Edit',
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Thumbnail Product'),
            const SizedBox(height: 8),
            _buildThumbnailPicker(),
            const SizedBox(height: 20),

            _buildSectionLabel('Product Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Example: Mobile App UI Kit',
              icon: Icons.label_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Product name cannot be empty';
                if (v.trim().length < 3) return 'Product name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildSectionLabel('Product Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Explain your digital product briefly...',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Description cannot be empty';
                if (v.trim().length < 10) return 'Description must be at least 10 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildSectionLabel('Price'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _priceController,
              hint: 'Example: 150000',
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'The price field cannot be left blank';
                final price = int.tryParse(v.trim());
                if (price == null || price <= 0) return 'Please enter a valid price';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildSectionLabel('Category'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 32),

            _buildSaveButton(),
            const SizedBox(height: 12),

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

  Widget _buildThumbnailPicker() {
    final bool hasNewImage = _newThumbnailFile != null;
    final String? oldImagePath = widget.product['file_path'] ?? widget.product['image'];
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
              if (hasNewImage)
                Image.file(_newThumbnailFile!, fit: BoxFit.cover)
              else if (hasOldImage)
                Image.network(
                  oldImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildThumbnailPlaceholder(),
                )
              else
                _buildThumbnailPlaceholder(),

              if (hasNewImage || hasOldImage)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, color: Colors.white, size: 14),
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

  // 🌟 Kategori Dropdown Dinamis
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF4), width: 1),
      ),
      child: _isLoadingCategories
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(color: Color(0xFF6B7FD7), strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading categories...', style: TextStyle(color: Color(0xFF9098B1), fontSize: 14)),
              ],
            ),
          )
        : DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            hint: const Row(
              children: [
                Icon(Icons.category_outlined, color: Color(0xFF9098B1), size: 20),
                SizedBox(width: 12),
                Text('Select product category', style: TextStyle(color: Color(0xFFB0B8CC), fontSize: 14)),
              ],
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9098B1)),
            borderRadius: BorderRadius.circular(12),
            onChanged: (String? value) => setState(() => _selectedCategory = value),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['id'].toString(), // Kirim ID
                child: Text(
                  category['nama'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D2E)),
                ),
              );
            }).toList(),
          ),
        ),
    );
  }

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
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}