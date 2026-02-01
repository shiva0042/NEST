import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/map_discovery/models/shop_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';



class StoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ShopModel> _shops = [];
  String? _userRole; // 'customer' or 'shopOwner'
  String _currentShopId = '1';
  ShopModel? _loggedInShop;
  bool _isLoading = false;

  List<ShopModel> get shops => _shops;
  String? get userRole => _userRole;
  String get currentShopId => _currentShopId;
  ShopModel? get loggedInShop => _loggedInShop;
  String? get currentShopName => _loggedInShop?.name;
  bool get isLoading => _isLoading;

  StoreProvider() {
    // Initial fetch
    fetchShops();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedShopId = prefs.getString('shop_id');
      
      if (savedShopId != null) {
        _currentShopId = savedShopId;
        _userRole = 'shopOwner';
        
        try {
          _loggedInShop = _shops.firstWhere((s) => s.id == savedShopId);
          debugPrint('Session restored for shop: ${_loggedInShop?.name}');
        } catch (e) {
          debugPrint('Saved shop ID not found in loaded shops');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }
  }

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  Future<void> fetchShops() async {
    try {
      final snapshot = await _firestore.collection(ShopModel.collectionName).get();
      final firestoreShops = snapshot.docs.map((doc) => ShopModel.fromMap(doc.data())).toList();
      
      // Merge logic: Use Firestore shops, but add missing baseline mock shops for testing
      // Merge logic: Use Firestore shops, but OVERRIDE coordinates from mock data if available
      // This ensures the map shows the correct hardcoded locations even if Firestore has old data
      _shops = [];
      for (var docShop in firestoreShops) {
        ShopModel finalShop = docShop;
        
        try {
          final matchedMock = mockShops.firstWhere(
            (m) => m.name == docShop.name || m.id == docShop.id
          );
          
          // Create new instance with UPDATED coordinates from mock
          finalShop = ShopModel(
            id: docShop.id,
            name: docShop.name,
            address: docShop.address,
            distance: docShop.distance,
            isOpen: docShop.isOpen,
            rating: docShop.rating,
            imageUrl: docShop.imageUrl,
            category: docShop.category,
            phoneNumber: docShop.phoneNumber,
            password: docShop.password,
            mapLink: matchedMock.mapLink, // Use updated link
            latitude: matchedMock.latitude, // FORCE UPDATE form mock
            longitude: matchedMock.longitude, // FORCE UPDATE from mock
          );
        } catch (_) {
          // No match found, keep original
        }
        _shops.add(finalShop);
      }

      // Add fully missing mocks
      for (var mock in mockShops) {
        if (!_shops.any((s) => s.id == mock.id || s.name == mock.name)) {
          _shops.add(mock);
        }
      }
      
      debugPrint('Loaded ${_shops.length} total shops (merged)');
      notifyListeners();
      _restoreSession();
    } catch (e) {
      debugPrint('Error fetching shops: $e');
      if (_shops.isEmpty) {
        _shops = List.from(mockShops);
        debugPrint('Using ${mockShops.length} mock shops as fallback');
        notifyListeners();
        _restoreSession();
      }
    }
  }

  Future<bool> loginShopOwner(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(ShopModel.collectionName)
          .where('phoneNumber', isEqualTo: phone)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final shop = ShopModel.fromMap(snapshot.docs.first.data());
        _loggedInShop = shop;
        _currentShopId = shop.id;
        _userRole = 'shopOwner';
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shop_id', shop.id);
        
        _isLoading = false;
        notifyListeners();
        debugPrint('Login successful for shop: ${shop.name}');
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      debugPrint('Login failed: Invalid credentials');
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> registerShop(String name, String phone, String password, String address, String category, String? mapLink) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newShopRef = _firestore.collection(ShopModel.collectionName).doc();
      final newShop = ShopModel(
        id: newShopRef.id,
        name: name,
        address: address,
        distance: 0.0,
        isOpen: true,
        rating: 5.0,
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
        category: category,
        phoneNumber: phone,
        password: password,
        mapLink: mapLink,
      );

      await newShopRef.set(newShop.toMap());
      _shops.add(newShop);
      
      // Auto login
      _loggedInShop = newShop;
      _currentShopId = newShop.id;
      _userRole = 'shopOwner';
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shop_id', newShop.id);
      
      _isLoading = false;
      notifyListeners();
      debugPrint('Shop registered successfully: ${newShop.name} with mapLink: $mapLink');
    } catch (e) {
      debugPrint('Registration error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loggedInShop = null;
    _userRole = null;
    _currentShopId = '1'; // Reset to default
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shop_id');
    
    notifyListeners();
  }

  Future<void> toggleShopStatus(String shopId) async {
    final index = _shops.indexWhere((s) => s.id == shopId);
    if (index != -1) {
      final shop = _shops[index];
      final newStatus = !shop.isOpen;
      
      // Optimistic update
      // We can't update 'final' fields, so we need to refetch or create a copy logic
      // But for Firestore, we just update the doc
      
      try {
        await _firestore.collection(ShopModel.collectionName).doc(shopId).update({
          'isOpen': newStatus
        });
        
        // Refresh local state by fetching again or manual update if desired
        fetchShops(); 
      } catch (e) {
        debugPrint('Error toggling status: $e');
      }
    }
  }
}
