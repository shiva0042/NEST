import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/cart_provider.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import 'cart_screen.dart';

class ShopDetailsView extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsView({super.key, required this.shop});

  @override
  State<ShopDetailsView> createState() => _ShopDetailsViewState();
}

class _ShopDetailsViewState extends State<ShopDetailsView> {
  String? selectedCategory;
  final ScrollController _categoryScrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _categoryScrollController.addListener(_updateArrowVisibility);
  }

  @override
  void dispose() {
    _categoryScrollController.removeListener(_updateArrowVisibility);
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _updateArrowVisibility() {
    setState(() {
      _showLeftArrow = _categoryScrollController.offset > 0;
      _showRightArrow = _categoryScrollController.offset < 
          _categoryScrollController.position.maxScrollExtent;
    });
  }

  void _scrollCategories(bool scrollRight) {
    const double scrollAmount = 250; // Scroll a bit more for smoother feel
    final double newOffset = scrollRight 
        ? _categoryScrollController.offset + scrollAmount
        : _categoryScrollController.offset - scrollAmount;
    _categoryScrollController.animateTo(
      newOffset.clamp(0, _categoryScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400), // Smoother, longer duration
      curve: Curves.easeOutCubic, // Smoother deceleration curve
    );
  }

  Future<void> _launchMaps() async {
    // Use the shop's Google Maps link if available
    final String mapUrl = widget.shop.mapLink ?? 
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.shop.address)}';
    final Uri url = Uri.parse(mapUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps')),
        );
      }
    }
  }

  void _showProductBottomSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = mockProducts.where((p) => p.shopId == widget.shop.id).toList();
    final categories = allProducts.map((p) => p.category).toSet().toList()..sort();
    
    final displayedProducts = selectedCategory == null 
        ? allProducts 
        : allProducts.where((p) => p.category == selectedCategory).toList();

    final Map<String, List<ProductModel>> groupedProducts = {};
    for (var product in displayedProducts) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }

    final List<dynamic> flatList = [];
    groupedProducts.forEach((category, products) {
      flatList.add(category);
      flatList.addAll(products);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.surface,
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.shop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.secondary.withOpacity(0.1),
                            child: const Icon(Icons.store_rounded, size: 64, color: AppColors.secondary),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.shop.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.shop.isOpen 
                                  ? AppColors.success.withOpacity(0.1) 
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.shop.isOpen ? 'OPEN' : 'CLOSED',
                              style: TextStyle(
                                color: widget.shop.isOpen ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.shop.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_rounded, color: AppColors.textLight, size: 18),
                          const SizedBox(width: 4),
                          Text(widget.shop.address, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _launchMaps,
                          icon: const Icon(Icons.directions_rounded, size: 18),
                          label: const Text('Get Directions'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Category Filter with scroll arrows
                      Row(
                        children: [
                          // Left Arrow
                          if (_showLeftArrow)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(2, 0),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                                onPressed: () => _scrollCategories(false),
                                iconSize: 24,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ),
                          // Category Chips
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _categoryScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(), // Smooth iOS-like scrolling
                              child: Row(
                                children: [
                                  _CategoryChip(
                                    label: 'All',
                                    isSelected: selectedCategory == null,
                                    onTap: () => setState(() => selectedCategory = null),
                                    count: allProducts.length,
                                  ),
                                  ...categories.map((category) {
                                    final count = allProducts.where((p) => p.category == category).length;
                                    return _CategoryChip(
                                      label: category,
                                      isSelected: selectedCategory == category,
                                      onTap: () => setState(() => selectedCategory = category),
                                      count: count,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          // Right Arrow
                          if (_showRightArrow)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(-2, 0),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                                onPressed: () => _scrollCategories(true),
                                iconSize: 24,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = flatList[index];
                      if (item is String) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        );
                      } else if (item is ProductModel) {
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
          // Floating Cart Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _FloatingCartBar(),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const _CategoryChip({
    required this.label, 
    required this.isSelected, 
    required this.onTap,
    this.count,
  });

  IconData _getCategoryIcon(String category) {
    final icons = {
      'All': Icons.apps_rounded,
      'Rice & Grains': Icons.rice_bowl_rounded,
      'Cooking Oil': Icons.water_drop_rounded,
      'Flour & Atta': Icons.bakery_dining_rounded,
      'Masala & Spices': Icons.local_fire_department_rounded,
      'Dairy': Icons.local_drink_rounded,
      'Beverages': Icons.coffee_rounded,
      'Tea & Coffee': Icons.coffee_rounded,
      'Cold Drinks': Icons.local_cafe_rounded,
      'Noodles': Icons.ramen_dining_rounded,
      'Biscuits': Icons.cookie_rounded,
      'Snacks': Icons.fastfood_rounded,
      'Chocolates': Icons.cake_rounded,
      'Chocolate Bars': Icons.icecream_rounded,
      'Premium Chocolates': Icons.star_rounded,
      'Spreads': Icons.breakfast_dining_rounded,
      'Jams & Honey': Icons.egg_alt_rounded,
      'Toppings & Syrups': Icons.water_drop_rounded,
      'Household': Icons.cleaning_services_rounded,
      'Vegetables': Icons.eco_rounded,
      'Fruits': Icons.apple_rounded,
      'Eggs': Icons.egg_rounded,
      'Bakery': Icons.bakery_dining_rounded,
      'Shampoo': Icons.wash_rounded,
      'Conditioner': Icons.water_drop_rounded,
      'Hair Oils': Icons.opacity_rounded,
      'Hair Serum': Icons.auto_awesome_rounded,
    };
    return icons[category] ?? Icons.category_rounded;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'All': Colors.grey,
      'Rice & Grains': Colors.orange,
      'Cooking Oil': Colors.amber,
      'Flour & Atta': Colors.brown,
      'Masala & Spices': Colors.red,
      'Dairy': Colors.blue,
      'Beverages': Colors.teal,
      'Tea & Coffee': Colors.brown,
      'Cold Drinks': Colors.cyan,
      'Noodles': Colors.yellow[700]!,
      'Biscuits': Colors.deepOrange,
      'Snacks': Colors.orange,
      'Chocolates': Colors.brown,
      'Chocolate Bars': Colors.brown[700]!,
      'Premium Chocolates': Colors.amber,
      'Spreads': Colors.orange,
      'Jams & Honey': Colors.red,
      'Toppings & Syrups': Colors.pink,
      'Household': Colors.indigo,
      'Vegetables': Colors.green,
      'Fruits': Colors.red,
      'Eggs': Colors.orange,
      'Bakery': Colors.brown,
      'Shampoo': Colors.purple,
      'Conditioner': Colors.pink,
      'Hair Oils': Colors.teal,
      'Hair Serum': Colors.deepPurple,
    };
    return colors[category] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getCategoryIcon(label);
    final color = _getCategoryColor(label);
    
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected 
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                size: 18, 
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.text,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final quantity = cart.getTotalQuantityForProduct(product.id);
        final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
        final discountPercent = hasDiscount 
            ? ((product.originalPrice! - product.price) / product.originalPrice! * 100).round()
            : 0;
        
        return GestureDetector(
          onTap: product.inStock ? onTap : null, // Disable tap for out of stock
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: quantity > 0 ? AppColors.primary.withOpacity(0.3) : AppColors.border.withOpacity(0.3),
                width: quantity > 0 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: quantity > 0 
                      ? AppColors.primary.withOpacity(0.08) 
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Product Image with gradient overlay
                        Stack(
                          children: [
                            Hero(
                              tag: 'product_${product.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    product.imageUrl.isNotEmpty && product.imageUrl.startsWith('http') 
                                        ? product.imageUrl 
                                        : 'https://tse2.mm.bing.net/th?q=${Uri.encodeComponent(product.name)}&w=100&h=100',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppColors.background, AppColors.surface],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textLight, size: 28),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Discount badge
                            if (hasDiscount)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '$discountPercent% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.brand.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Product name
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Price row
                              Row(
                                children: [
                                  Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${product.originalPrice!.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: AppColors.textLight,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add/Quantity Button
                        _buildActionButton(cart, quantity),
                      ],
                    ),
                  ),
                  // Out of stock overlay
                  if (!product.inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, color: AppColors.error, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(CartProvider cart, int quantity) {
    if (quantity > 0) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withBlue(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                final items = cart.items.entries.where((e) => e.value.product.id == product.id).toList();
                if (items.isNotEmpty) {
                  cart.removeSingleItem(items.last.key);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.remove_rounded, color: Colors.white, size: 18),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      );
    }
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ADD',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.add_rounded, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailSheet extends StatefulWidget {
  final ProductModel product;

  const _ProductDetailSheet({required this.product});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  late String selectedSize;
  
  @override
  void initState() {
    super.initState();
    // Set default size based on product unit
    final options = sizeOptionsByUnit[widget.product.unit] ?? sizeOptionsByUnit['weight']!;
    selectedSize = options.length > 1 ? options[1].name : options[0].name;
  }
  
  List<SizeOption> get sizeOptions {
    return sizeOptionsByUnit[widget.product.unit] ?? sizeOptionsByUnit['weight']!;
  }

  double get currentPrice {
    final option = sizeOptions.firstWhere((s) => s.name == selectedSize, orElse: () => sizeOptions[0]);
    return widget.product.price * option.multiplier;
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
                Stack(
                  children: [
                    Hero(
                      tag: 'product_${widget.product.id}',
                      child: ClipRRect(
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
                    ),
                    // Out of stock overlay on image
                    if (!widget.product.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OUT OF\nSTOCK',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
                      const SizedBox(height: 8),
                      // Out of stock badge
                      if (!widget.product.inStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_outlined, color: AppColors.error, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Currently Unavailable',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Text(
                              '₹${currentPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            if (widget.product.originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${(widget.product.originalPrice! * (sizeOptions.firstWhere((s) => s.name == selectedSize, orElse: () => sizeOptions[0]).multiplier)).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
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
                  'Select Size',
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
          // Add to Cart Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SafeArea(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final quantity = cart.getQuantity(widget.product.id, size: selectedSize);
                  
                  if (quantity > 0) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cart.removeSingleItem('${widget.product.id}_$selectedSize');
                                    if (cart.getQuantity(widget.product.id, size: selectedSize) == 0) {
                                      // Optionally close sheet when last item removed
                                    }
                                  },
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () => cart.addItem(widget.product, size: selectedSize),
                                  icon: const Icon(Icons.add, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '₹${(currentPrice * quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  // Show out of stock button if product is unavailable
                  if (!widget.product.inStock) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: null, // Disabled
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Out of Stock',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addItem(widget.product, size: selectedSize);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${widget.product.name} ($selectedSize) to cart'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
                          const Icon(Icons.add_shopping_cart_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Add to Cart  •  ₹${currentPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCartBar extends StatefulWidget {
  @override
  State<_FloatingCartBar> createState() => _FloatingCartBarState();
}

class _FloatingCartBarState extends State<_FloatingCartBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.itemCount == 0) return const SizedBox.shrink();
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E3A5F),
                  Color(0xFF2D5A87),
                  Color(0xFF1E3A5F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    children: [
                      // Animated cart icon with count badge
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B35).withOpacity(0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Cart info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''} in cart',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.local_offer_rounded, color: Colors.white.withOpacity(0.7), size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'Extra savings on checkout!',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // View Cart button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF1E3A5F),
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A5F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
