import 'package:flutter/material.dart';
import '../../features/map_discovery/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final String selectedSize;
  int quantity;

  CartItem({required this.product, required this.selectedSize, this.quantity = 1});

  double get total => product.price * quantity;
  
  // Unique key combines product ID and size
  String get uniqueKey => '${product.id}_$selectedSize';
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  int get uniqueItemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.total;
    });
    return total;
  }

  void addItem(ProductModel product, {String size = 'Standard'}) {
    final key = '${product.id}_$size';
    if (_items.containsKey(key)) {
      _items.update(
        key,
        (existingItem) => CartItem(
          product: existingItem.product,
          selectedSize: existingItem.selectedSize,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        key,
        () => CartItem(product: product, selectedSize: size),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String key) {
    if (!_items.containsKey(key)) {
      return;
    }
    if (_items[key]!.quantity > 1) {
      _items.update(
        key,
        (existingItem) => CartItem(
          product: existingItem.product,
          selectedSize: existingItem.selectedSize,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
  
  int getQuantity(String productId, {String size = 'Standard'}) {
    final key = '${productId}_$size';
    return _items.containsKey(key) ? _items[key]!.quantity : 0;
  }
  
  int getTotalQuantityForProduct(String productId) {
    int total = 0;
    _items.forEach((key, item) {
      if (item.product.id == productId) {
        total += item.quantity;
      }
    });
    return total;
  }
}
