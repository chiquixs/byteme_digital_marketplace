// ============================================================
// CART MANAGER - Singleton untuk state keranjang lintas halaman
// Letakkan file ini di: lib/utils/cart_manager.dart
// TODO(backend): Ganti dengan CartController + Provider/Riverpod
// ============================================================

class CartManager {
  CartManager._();
  static final CartManager instance = CartManager._();

  final List<Map<String, dynamic>> _items = [];
  final List<void Function()> _listeners = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  int get totalItems => _items.length;

  bool isInCart(Map<String, dynamic> product) {
    return _items.any((p) => p['title'] == product['title']);
  }

  /// Tambah produk ke keranjang.
  /// Karena produk digital, cukup 1 item per produk.
  /// Return false jika produk sudah ada di keranjang.
  bool addToCart(Map<String, dynamic> product) {
    if (isInCart(product)) return false;

    // Normalize data supaya CartPage bisa baca
    _items.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'store': product['seller'] ?? 'Official Store',
      'name': product['title'] ?? '',
      'price': product['priceLabel'] ?? product['price'] ?? 'Rp 0',
      'qty': 1,
      'selected': false,
      'image': product['image'] ?? '',
      'category': product['category'] ?? '',
      // Simpan data asli untuk navigasi ke detail
      'originalProduct': Map<String, dynamic>.from(product),
    });

    _notify();
    return true;
  }

  void removeFromCart(String title) {
    _items.removeWhere((p) => p['name'] == title);
    _notify();
  }

  void clearCart() {
    _items.clear();
    _notify();
  }

  void addListener(void Function() cb) => _listeners.add(cb);
  void removeListener(void Function() cb) => _listeners.remove(cb);

  void _notify() {
    for (final cb in _listeners) {
      cb();
    }
  }
}
