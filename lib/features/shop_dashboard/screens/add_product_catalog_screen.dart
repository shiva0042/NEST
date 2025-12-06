import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../map_discovery/models/product_model.dart';

class AddProductCatalogScreen extends StatefulWidget {
  final Function(ProductModel, String selectedSize, double priceForSize) onProductAdded;

  const AddProductCatalogScreen({super.key, required this.onProductAdded});

  @override
  State<AddProductCatalogScreen> createState() => _AddProductCatalogScreenState();
}

class _AddProductCatalogScreenState extends State<AddProductCatalogScreen> {
  bool _isLoading = true;
  List<ProductModel> _catalogProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    // 1. Try loading real scraped products first
    try {
      final String collectedJson = await rootBundle.loadString('assets/data/collected_products.json');
      final List<dynamic> collectedList = json.decode(collectedJson);
      
      final List<ProductModel> realProducts = collectedList.map((j) {
        var p = ProductModel.fromJson(j);
        return ProductModel(
          id: 'catalog_${p.id}',
          shopId: 'catalog',
          name: p.name,
          price: p.price,
          originalPrice: p.originalPrice,
          imageUrl: p.imageUrl,
          inStock: true,
          stockQuantity: 10,
          category: p.category,
          brand: p.brand,
          unit: p.unit,
        );
      }).toList();

      Set<String> categories = {'All'};
      for(var p in realProducts) {
        categories.add(p.category);
      }
      
      if (mounted) {
        setState(() {
          _catalogProducts = realProducts;
          _filteredProducts = realProducts;
          _categories = categories.toList();
          _isLoading = false;
        });
        return; 
      }
    } catch(e) {
      debugPrint("No collected products found, falling back to mock: $e");
    }

    // 2. Fallback to mock products
    setState(() {
      // Use unique products from mockProducts
      Set<String> seenNames = {};
      List<ProductModel> uniqueProducts = [];
      
      for (var p in mockProducts) {
        if (!seenNames.contains(p.name)) {
          seenNames.add(p.name);
          uniqueProducts.add(ProductModel(
            id: 'catalog_${p.id}',
            shopId: 'catalog',
            name: p.name,
            price: p.price,
            originalPrice: p.originalPrice,
            imageUrl: p.imageUrl,
            inStock: true,
            stockQuantity: 10,
            category: p.category,
            brand: p.brand,
            unit: p.unit,
          ));
        }
      }
      
      Set<String> categories = {'All'};
      for (var p in uniqueProducts) {
        categories.add(p.category);
      }
      
      _catalogProducts = uniqueProducts;
      _filteredProducts = uniqueProducts;
      _categories = categories.toList()..sort();
      _isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _catalogProducts.where((p) {
        bool matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                             p.brand.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _showProductBottomSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(
        product: product,
        onAddProduct: (product, size, price) {
          widget.onProductAdded(product, size, price);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${product.name} ($size) added to inventory!"),
              duration: const Duration(milliseconds: 1200),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            )
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group products by category
    Map<String, List<ProductModel>> groupedProducts = {};
    for (var product in _filteredProducts) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }

    // Flatten for list display
    List<dynamic> flatList = [];
    groupedProducts.forEach((category, products) {
      flatList.add(category);
      flatList.addAll(products);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Add Products to Inventory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select products and sizes to add',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterProducts();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search products, brands...',
                    hintStyle: TextStyle(color: AppColors.textLight),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
          
          // Category Filter
          if (!_isLoading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _filterProducts();
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            boxShadow: isSelected 
                                ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                                : [],
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.text,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // Products List (same style as customer view)
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_filteredProducts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: AppColors.textLight),
                    SizedBox(height: 16),
                    Text('No products found', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = flatList[index];
                    if (item is String) {
                      // Category Header
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (item is ProductModel) {
                      // Product Card
                      return _ProductCard(
                        product: item,
                        onTap: () => _showProductBottomSheet(context, item),
                      );
                    }
                    return null;
                  },
                  childCount: flatList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Product Card - Same style as customer view
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl.isNotEmpty && product.imageUrl.startsWith('http') 
                    ? product.imageUrl 
                    : 'https://tse2.mm.bing.net/th?q=${Uri.encodeComponent(product.name)}&w=100&h=100',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: AppColors.background,
                    child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textLight),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '(base price)',
                        style: TextStyle(fontSize: 10, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Add Button
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'ADD',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Detail Bottom Sheet - Same style as customer view
class _ProductDetailSheet extends StatefulWidget {
  final ProductModel product;
  final Function(ProductModel, String, double) onAddProduct;

  const _ProductDetailSheet({required this.product, required this.onAddProduct});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  late String selectedSize;
  int quantity = 1;
  bool useCustomPrice = false;
  late TextEditingController _customPriceController;
  
  @override
  void initState() {
    super.initState();
    final options = sizeOptionsByUnit[widget.product.unit] ?? sizeOptionsByUnit['weight']!;
    selectedSize = options.length > 1 ? options[1].name : options[0].name;
    _customPriceController = TextEditingController();
  }
  
  @override
  void dispose() {
    _customPriceController.dispose();
    super.dispose();
  }
  
  List<SizeOption> get sizeOptions {
    return sizeOptionsByUnit[widget.product.unit] ?? sizeOptionsByUnit['weight']!;
  }

  double get suggestedPrice {
    final option = sizeOptions.firstWhere((s) => s.name == selectedSize, orElse: () => sizeOptions[0]);
    return widget.product.price * option.multiplier;
  }
  
  double get currentPrice {
    if (useCustomPrice && _customPriceController.text.isNotEmpty) {
      return double.tryParse(_customPriceController.text) ?? suggestedPrice;
    }
    return suggestedPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Product Image & Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.product.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.brand,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.product.category,
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${currentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Size Selection
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Size / Variant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: sizeOptions.map((size) {
                    final isSelected = selectedSize == size.name;
                    final price = widget.product.price * size.multiplier;
                    return InkWell(
                      onTap: () => setState(() => selectedSize = size.name),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              size.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primary : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              size.label,
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isSelected ? AppColors.primary : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Custom Price Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: useCustomPrice ? AppColors.primary.withOpacity(0.05) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: useCustomPrice ? AppColors.primary.withOpacity(0.3) : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Set Custom Price',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Suggested: ₹${suggestedPrice.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: useCustomPrice,
                        onChanged: (val) => setState(() {
                          useCustomPrice = val;
                          if (val) {
                            _customPriceController.text = suggestedPrice.toStringAsFixed(0);
                          }
                        }),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (useCustomPrice) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: TextField(
                        controller: _customPriceController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          hintText: 'Enter your selling price',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Your margin: ₹${(currentPrice - suggestedPrice).toStringAsFixed(0)} (${((currentPrice / suggestedPrice - 1) * 100).toStringAsFixed(1)}%)',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stock Quantity Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Initial Stock Quantity',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How many units to add to your inventory?',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => quantity = (quantity > 1) ? quantity - 1 : 1),
                        icon: const Icon(Icons.remove, size: 18),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add, size: 18),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Add to Inventory Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddProduct(widget.product, selectedSize, currentPrice);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_business_rounded),
                      const SizedBox(width: 10),
                      Text(
                        'Add to Inventory  •  $quantity × ₹${currentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
