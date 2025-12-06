import 'package:flutter/foundation.dart'; // Add for debugPrint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Service - Central access point for all Firebase operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  
  // Current user
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==========================================
  // AUTHENTICATION METHODS
  // ==========================================

  /// Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification (Android only)
          onAutoVerify(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verify OTP and sign in
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==========================================
  // FIRESTORE - SHOPS
  // ==========================================
  
  CollectionReference get shopsCollection => _firestore.collection('shops');

  /// Create a new shop
  Future<String?> createShop(Map<String, dynamic> shopData) async {
    try {
      final docRef = await shopsCollection.add({
        ...shopData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating shop: $e');
      return null;
    }
  }

  /// Get shop by ID
  Future<Map<String, dynamic>?> getShop(String shopId) async {
    try {
      final doc = await shopsCollection.doc(shopId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      debugPrint('Error getting shop: $e');
      return null;
    }
  }

  /// Get shops by owner phone number
  Future<List<Map<String, dynamic>>> getShopsByOwner(String phone) async {
    try {
      final query = await shopsCollection
          .where('phone', isEqualTo: phone)
          .get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      debugPrint('Error getting shops: $e');
      return [];
    }
  }

  /// Get nearby shops (requires geohash indexing for production)
  Future<List<Map<String, dynamic>>> getNearbyShops({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) async {
    try {
      // Note: For production, use GeoFlutterFire for efficient geo queries
      final query = await shopsCollection.limit(50).get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      debugPrint('Error getting nearby shops: $e');
      return [];
    }
  }

  /// Update shop
  Future<bool> updateShop(String shopId, Map<String, dynamic> data) async {
    try {
      await shopsCollection.doc(shopId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating shop: $e');
      return false;
    }
  }

  /// Toggle shop open/closed status
  Future<bool> toggleShopStatus(String shopId, bool isOpen) async {
    return updateShop(shopId, {'isOpen': isOpen});
  }

  // ==========================================
  // FIRESTORE - PRODUCTS (Global Catalog)
  // ==========================================

  CollectionReference get productsCollection => _firestore.collection('products');

  /// Add product to global catalog
  Future<String?> addProduct(Map<String, dynamic> productData) async {
    try {
      final docRef = await productsCollection.add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return null;
    }
  }

  /// Get all products
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final query = await productsCollection.get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      final query = await productsCollection
          .where('category', isEqualTo: category)
          .get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // ==========================================
  // FIRESTORE - SHOP INVENTORY
  // ==========================================

  CollectionReference shopInventory(String shopId) =>
      shopsCollection.doc(shopId).collection('inventory');

  /// Add item to shop inventory
  Future<bool> addToInventory(String shopId, Map<String, dynamic> item) async {
    try {
      await shopInventory(shopId).add({
        ...item,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding to inventory: $e');
      return false;
    }
  }

  /// Get shop inventory
  Future<List<Map<String, dynamic>>> getInventory(String shopId) async {
    try {
      final query = await shopInventory(shopId).get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      debugPrint('Error getting inventory: $e');
      return [];
    }
  }

  /// Update inventory item
  Future<bool> updateInventoryItem(
    String shopId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      await shopInventory(shopId).doc(itemId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating inventory item: $e');
      return false;
    }
  }

  /// Decrement stock (after sale)
  Future<bool> decrementStock(String shopId, String itemId, int quantity) async {
    try {
      await shopInventory(shopId).doc(itemId).update({
        'stockQty': FieldValue.increment(-quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error decrementing stock: $e');
      return false;
    }
  }

  // ==========================================
  // FIRESTORE - BILLS
  // ==========================================

  CollectionReference shopBills(String shopId) =>
      shopsCollection.doc(shopId).collection('bills');

  /// Create a bill
  Future<String?> createBill(String shopId, Map<String, dynamic> billData) async {
    try {
      final docRef = await shopBills(shopId).add({
        ...billData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating bill: $e');
      return null;
    }
  }

  /// Get bills for a shop
  Future<List<Map<String, dynamic>>> getBills(String shopId, {int limit = 50}) async {
    try {
      final query = await shopBills(shopId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      debugPrint('Error getting bills: $e');
      return [];
    }
  }

  // ==========================================
  // FIREBASE STORAGE
  // ==========================================

  /// Upload image and get download URL
  Future<String?> uploadImage(String path, dynamic file) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image
  Future<bool> deleteImage(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}
