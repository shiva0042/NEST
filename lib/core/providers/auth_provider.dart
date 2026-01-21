import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _userPhone;

  bool get isLoading => _isLoading;
  String? get userPhone => _userPhone;

  AuthProvider() {
    // Check if user is already logged in (from local storage if needed)
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // You could implement persistent login here using shared_preferences
    // For now, we'll just keep it simple
  }

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> signIn(String phone, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final hashedPassword = _hashPassword(password);
      
      // Query Firestore for user
      final userDoc = await _firestore
          .collection('users')
          .doc(phone)
          .get();

      if (!userDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return 'No account found with this phone number';
      }

      final userData = userDoc.data()!;
      if (userData['password'] != hashedPassword) {
        _isLoading = false;
        notifyListeners();
        return 'Incorrect password';
      }

      _userPhone = phone;
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred: $e';
    }
  }

  Future<String?> signUp(String phone, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user already exists
      final userDoc = await _firestore
          .collection('users')
          .doc(phone)
          .get();

      if (userDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return 'An account already exists with this phone number';
      }

      final hashedPassword = _hashPassword(password);
      
      // Create new user
      await _firestore.collection('users').doc(phone).set({
        'phone': phone,
        'password': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _userPhone = phone;
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred: $e';
    }
  }

  Future<void> signOut() async {
    _userPhone = null;
    notifyListeners();
  }

  String? validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character';
    }
    return null;
  }
}
