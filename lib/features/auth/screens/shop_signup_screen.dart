import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../shop_dashboard/screens/dashboard_screen.dart';

class ShopSignUpScreen extends StatefulWidget {
  const ShopSignUpScreen({super.key});

  @override
  State<ShopSignUpScreen> createState() => _ShopSignUpScreenState();
}

class _ShopSignUpScreenState extends State<ShopSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passkeyController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapLinkController = TextEditingController();
  String _selectedCategory = 'Grocery';
  final List<String> _categories = ['Grocery', 'Supermarket', 'Fruits & Veg', 'Bakery', 'Stationery'];
  bool _isLoading = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      context.read<StoreProvider>().registerShop(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _passkeyController.text.trim(),
        _addressController.text.trim(),
        _selectedCategory,
        _mapLinkController.text.trim().isNotEmpty 
            ? _mapLinkController.text.trim() 
            : null,
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop Registered Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Dashboard directly
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ShopOwnerDashboard()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.text),
        title: Text(
          'Register Shop',
          style: TextStyle(color: isDark ? Colors.white : AppColors.text, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 1. Liquid Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFE0F7FA), const Color(0xFFE3F2FD)],
              ),
            ),
          ),

          // 2. Ambient Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [AppColors.primary.withOpacity(0.15), Colors.transparent]
                      : [Colors.blue.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [const Color(0xFFFF9800).withOpacity(0.1), Colors.transparent]
                      : [Colors.orange.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          // 3. Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create Your Shop',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join NEST and reach more customers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildGlassTextField(
                            controller: _nameController,
                            label: 'Shop Name',
                            icon: Icons.store_rounded,
                            isDark: isDark,
                            validator: (v) => v!.isEmpty ? 'Enter shop name' : null,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                prefixIcon: Icon(Icons.category_rounded, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val!),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_android_rounded,
                            isDark: isDark,
                            inputType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _passkeyController,
                            label: 'Passkey',
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            obscureText: true,
                            inputType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Enter Passkey' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _addressController,
                            label: 'Address',
                            icon: Icons.location_on_outlined,
                            isDark: isDark,
                            validator: (v) => v!.isEmpty ? 'Enter address' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _mapLinkController,
                            label: 'Google Maps Link (Optional)',
                            icon: Icons.map_outlined,
                            isDark: isDark,
                            hint: 'https://maps.app.goo.gl/...',
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Register Shop',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
        prefixIcon: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }
}
