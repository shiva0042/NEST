import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Simulating fetching products for shop 1
  late List<ProductModel> _products;

  @override
  void initState() {
    super.initState();
    final shopId = context.read<StoreProvider>().currentShopId;
    _products = mockProducts.where((p) => p.shopId == shopId).toList();
  }

  void _updateStock(ProductModel product, int newQuantity) {
    setState(() {
      // Create updated product
      final updatedProduct = ProductModel(
        id: product.id,
        shopId: product.shopId,
        name: product.name,
        price: product.price,
        originalPrice: product.originalPrice,
        imageUrl: product.imageUrl,
        inStock: newQuantity > 0,
        stockQuantity: newQuantity,
        category: product.category,
        brand: product.brand,
      );

      // Update local list
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      // Update global mock list to persist changes across screens
      final globalIndex = mockProducts.indexWhere((p) => p.id == product.id);
      if (globalIndex != -1) {
        mockProducts[globalIndex] = updatedProduct;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Inventory Management',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: AppColors.text),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Stock',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: AppColors.secondary),
                            onPressed: () {
                              if (product.stockQuantity > 0) {
                                _updateStock(product, product.stockQuantity - 1);
                              }
                            },
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              '${product.stockQuantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: product.stockQuantity < 10 ? Colors.red : AppColors.text,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              _updateStock(product, product.stockQuantity + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new product logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add Product coming soon')),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add),
      ),
    );
  }
}
