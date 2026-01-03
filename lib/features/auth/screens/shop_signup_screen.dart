import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: const Text('Register Shop', style: TextStyle(color: AppColors.text)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Enter shop name' : null,
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passkeyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Passkey',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Enter Passkey' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mapLinkController,
                decoration: InputDecoration(
                  labelText: 'Google Maps Link (Optional)',
                  hintText: 'https://maps.app.goo.gl/...',
                  prefixIcon: const Icon(Icons.map_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                  helperText: 'Share your location from Google Maps',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Register Shop',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
