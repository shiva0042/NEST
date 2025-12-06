import 'package:flutter/material.dart';
import '../../features/map_discovery/models/shop_model.dart';

class StoreProvider extends ChangeNotifier {
  final List<ShopModel> _shops = mockShops;
  String? _userRole; // 'customer' or 'shopOwner'
  String _currentShopId = '1';
  ShopModel? _loggedInShop;

  List<ShopModel> get shops => _shops;
  String? get userRole => _userRole;
  String get currentShopId => _currentShopId;
  ShopModel? get loggedInShop => _loggedInShop;
  String? get currentShopName => _loggedInShop?.name;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  bool loginShopOwner(String phone, String password) {
    try {
      final shop = _shops.firstWhere(
        (s) => s.phoneNumber == phone && s.password == password,
      );
      _loggedInShop = shop;
      _currentShopId = shop.id;
      _userRole = 'shopOwner';
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void registerShop(String name, String phone, String password, String address) {
    final newShop = ShopModel(
      id: '${_shops.length + 1}',
      name: name,
      address: address,
      distance: 0.0, // New shops start with 0 distance for now
      isOpen: true,
      rating: 5.0, // New shops start with 5 stars
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e', // Default image
      category: 'Grocery',
      phoneNumber: phone,
      password: password,
    );
    _shops.add(newShop);
    notifyListeners();
  }

  void logout() {
    _loggedInShop = null;
    _userRole = null;
    notifyListeners();
  }

  void toggleShopStatus(String shopId) {
    final index = _shops.indexWhere((s) => s.id == shopId);
    if (index != -1) {
      final shop = _shops[index];
      _shops[index] = ShopModel(
        id: shop.id,
        name: shop.name,
        address: shop.address,
        distance: shop.distance,
        isOpen: !shop.isOpen,
        rating: shop.rating,
        imageUrl: shop.imageUrl,
        category: shop.category,
        phoneNumber: shop.phoneNumber,
        password: shop.password,
      );
      notifyListeners();
    }
  }
}
