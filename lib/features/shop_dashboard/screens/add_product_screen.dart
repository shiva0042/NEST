import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedCategory = 'Grocery';
  String _selectedBrand = 'Local';
  String _selectedUnit = 'weight';
  bool _isLoading = false;

  final List<String> _categories = [
    'Grocery', 'Dairy', 'Beverages', 'Snacks', 'Biscuits', 'Staples',
    'Dals & Pulses', 'Oils & Ghee', 'Spices', 'Noodles', 'Household',
    'Vegetables', 'Fruits', 'Eggs', 'Bakery', 'Ice Cream', 'Shampoo',
    'Conditioner', 'Hair Oils', 'Hair Serum', 'Baby Care', 'Pet Care'
  ];

  final List<String> _units = ['weight', 'volume', 'pack', 'pieces'];

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storeProvider = context.read<StoreProvider>();
      final shopId = storeProvider.currentShopId;
      final firestore = FirebaseFirestore.instance;

      // Generate new product ID
      final productRef = firestore.collection('products').doc();
      
      final product = {
        'id': productRef.id,
        'shopId': shopId,
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'originalPrice': null,
        'imageUrl': _imageUrlController.text.trim().isEmpty
            ? 'https://via.placeholder.com/300x300.png?text=Product'
            : _imageUrlController.text.trim(),
        'inStock': true,
        'stockQuantity': int.parse(_stockController.text),
        'category': _selectedCategory,
        'brand': _selectedBrand,
        'unit': _selectedUnit,
      };

      await productRef.set(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '✅ Uploaded to Firebase!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${_nameController.text} is now live for all users on web & mobile',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                // Could navigate to billing screen
              },
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Firebase upload failed: $e')),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: Theme.of(context).cardColor,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        titleTextStyle: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: _buildInputDecoration(
                  context,
                  label: 'Product Name',
                  hint: 'e.g., Amul Butter 100g',
                  icon: Icons.shopping_bag_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Brand
              TextFormField(
                initialValue: _selectedBrand,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: _buildInputDecoration(
                  context,
                  label: 'Brand',
                  hint: 'e.g., Amul, Britannia',
                  icon: Icons.branding_watermark_outlined,
                ),
                onChanged: (value) => _selectedBrand = value,
              ),
              const SizedBox(height: 16),

              // Price and Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: _buildInputDecoration(
                        context,
                        label: 'Price (₹)',
                        icon: Icons.currency_rupee_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: _buildInputDecoration(
                        context,
                        label: 'Stock Qty',
                        icon: Icons.inventory_2_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
                dropdownColor: Theme.of(context).cardColor,
                decoration: _buildInputDecoration(
                  context,
                  label: 'Category',
                  icon: Icons.category_outlined,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),

              // Unit Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
                dropdownColor: Theme.of(context).cardColor,
                decoration: _buildInputDecoration(
                  context,
                  label: 'Unit Type',
                  icon: Icons.straighten_rounded,
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedUnit = value!);
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: _buildInputDecoration(
                  context,
                  label: 'Image URL (Optional)',
                  hint: 'https://example.com/image.jpg',
                  icon: Icons.image_outlined,
                ),
              ),
              const SizedBox(height: 24),

              // Add Button
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Product',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
