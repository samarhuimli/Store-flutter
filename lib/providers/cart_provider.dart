import 'package:flutter/foundation.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  String? _userId;

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.length;

  int quantityFor(ProductModel product) =>
      _items[product.id]?.quantity ?? 0;

  double get totalPrice => _items.values
      .fold(0.0, (sum, item) => sum + item.totalPrice);

  void setUser(String userId) {
    _userId = userId;
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    if (_userId == null) return;
    final products = await CartServiceApi.getCartProducts(_userId!);

    _items.clear();
    // Le backend stocke une liste de produits (avec doublons possibles pour la quantité)
    for (final p in products) {
      if (_items.containsKey(p.id)) {
        _items[p.id]!.quantity += 1;
      } else {
        _items[p.id] = CartItem(product: p, quantity: 1);
      }
    }
    notifyListeners();
  }

  void addToCart(ProductModel product, {int quantity = 1, bool syncBackend = true}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    if (_userId != null && syncBackend) {
      for (var i = 0; i < quantity; i++) {
        CartServiceApi.addToCart(_userId!, product.id);
      }
    }
    notifyListeners();
  }

  void removeOne(ProductModel product, {bool syncBackend = true}) {
    if (!_items.containsKey(product.id)) return;

    final current = _items[product.id]!;
    if (current.quantity > 1) {
      current.quantity -= 1;
    } else {
      _items.remove(product.id);
    }
    if (_userId != null && syncBackend) {
      CartServiceApi.removeFromCart(_userId!, product.id);
    }
    notifyListeners();
  }

  void removeItem(ProductModel product) {
    if (_items.remove(product.id) != null) {
      if (_userId != null) {
        // Supprimer toutes les occurrences en backend
        CartServiceApi.removeFromCart(_userId!, product.id);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    if (_userId != null) {
      CartServiceApi.clearCart(_userId!);
    }
    notifyListeners();
  }
}
