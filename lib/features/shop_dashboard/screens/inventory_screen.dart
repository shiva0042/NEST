import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';
import 'add_product_catalog_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Simulating fetching products for shop 1
  List<ProductModel> _allProducts = []; // Master list
  List<ProductModel> _displayedProducts = []; // Filtered List
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final shopId = context.read<StoreProvider>().currentShopId;
    
    try {
      // Try to load real scraped data
      final String jsonString = await rootBundle.loadString('assets/data/collected_products.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<ProductModel> loadedProducts = jsonList.map((j) {
        var p = ProductModel.fromJson(j);
        return ProductModel(
          id: p.id,
          shopId: shopId,
          name: p.name,
          price: p.price,
          originalPrice: p.originalPrice,
          imageUrl: p.imageUrl,
          inStock: p.inStock,
          stockQuantity: p.stockQuantity,
          category: p.category,
          brand: p.brand
        );
      }).toList();

      _updateStateWithProducts(loadedProducts);

    } catch (e) {
      // Fallback to mock data if file not found or error
      debugPrint('Error loading collected items, using mock: $e');
      _updateStateWithProducts(mockProducts.where((p) => p.shopId == shopId).toList());
    }
  }

  void _updateStateWithProducts(List<ProductModel> products) {
    // Extract Categories
    Set<String> cats = {'All'};
    for (var p in products) {
      cats.add(p.category);
    }

    if (mounted) {
      setState(() {
        _allProducts = products;
        _categories = cats.toList();
        _filterProducts(); // Initial filter
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _displayedProducts = _allProducts.where((p) {
        bool matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
        bool matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
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

      // Update local master list
      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index] = updatedProduct;
      }
      _filterProducts(); // Re-apply filter to update view

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
        title: const Text(
          'Inventory Management',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
            children: [
              // Search & Filter Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                     Padding(
                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                       child: TextField(
                          onChanged: (val) {
                            _searchQuery = val;
                            _filterProducts();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search inventory...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            fillColor: Colors.grey[100],
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.zero
                          ),
                       ),
                     ),
                     SizedBox(
                      height: 40,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_,__) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                                _filterProducts();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300)
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _displayedProducts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl.isNotEmpty && product.imageUrl.startsWith('http') 
                                    ? product.imageUrl 
                                    : 'https://placehold.co/100x100?text=${Uri.encodeComponent(product.name)}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.network(
                                   'https://tse2.mm.bing.net/th?q=${Uri.encodeComponent(product.name)}&w=100&h=100&c=7&rs=1&p=0',
                                   width: 60, height: 60, fit: BoxFit.cover,
                                   errorBuilder: (_,__,___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported),
                                   )
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Stock',
                                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondary),
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
                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
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
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductCatalogScreen(
                onProductAdded: (newProduct, selectedSize, price) {
                  // Add to inventory with selected size and custom price
                  setState(() {
                      // Create product name with size
                      String productNameWithSize = '${newProduct.name} ($selectedSize)';
                      
                      // Check if exists
                      final index = _allProducts.indexWhere((p) => p.name == productNameWithSize);
                      if (index == -1) {
                         // Assign current Shop ID
                         final shopId = context.read<StoreProvider>().currentShopId;
                         final productToAdd = ProductModel(
                           id: DateTime.now().millisecondsSinceEpoch.toString(),
                           shopId: shopId,
                           name: productNameWithSize,
                           price: price, // Use custom/selected price
                           originalPrice: newProduct.originalPrice != null 
                               ? newProduct.originalPrice! * (price / newProduct.price)
                               : null,
                           imageUrl: newProduct.imageUrl,
                           inStock: true,
                           stockQuantity: 10,
                           category: newProduct.category,
                           brand: newProduct.brand,
                           unit: newProduct.unit,
                         );
                         _allProducts.add(productToAdd);
                         mockProducts.add(productToAdd); // Sync with customer view
                      } else {
                         // Increment stock
                         _updateStock(_allProducts[index], _allProducts[index].stockQuantity + 1);
                      }
                      _updateStateWithProducts(_allProducts); // Re-calc categories and filtering
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
      ),
    );
  }
}    
