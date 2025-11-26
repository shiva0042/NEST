import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/shop_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ShopDetailsView extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsView({super.key, required this.shop});

  @override
  State<ShopDetailsView> createState() => _ShopDetailsViewState();
}

class _ShopDetailsViewState extends State<ShopDetailsView> {
  String? selectedCategory;

  Future<void> _launchMaps() async {
    // Using a generic query for now since we don't have lat/lng in ShopModel yet
    // In a real app, use: 'google.navigation:q=${widget.shop.latitude},${widget.shop.longitude}'
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.shop.address)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = mockProducts.where((p) => p.shopId == widget.shop.id).toList();
    final categories = allProducts.map((p) => p.category).toSet().toList()..sort();
    
    // Filter products if a category is selected
    final displayedProducts = selectedCategory == null 
        ? allProducts 
        : allProducts.where((p) => p.category == selectedCategory).toList();

    // Group products by category for the list view
    final Map<String, List<ProductModel>> groupedProducts = {};
    for (var product in displayedProducts) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }

    // Flatten the map to a list for the SliverList
    final List<dynamic> flatList = [];
    groupedProducts.forEach((category, products) {
      flatList.add(category); // String implies header
      flatList.addAll(products); // ProductModel implies item
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
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
                        child: Icon(Icons.store_rounded, size: 64, color: AppColors.secondary),
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
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                // Glassmorphism requires BackdropFilter widget usually, but simple opacity works for now
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.shop.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.shop.isOpen 
                              ? AppColors.success.withOpacity(0.1) 
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: widget.shop.isOpen 
                                ? AppColors.success.withOpacity(0.2) 
                                : AppColors.error.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          widget.shop.isOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            color: widget.shop.isOpen ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.secondary, size: 20),
                      SizedBox(width: 4),
                      Text(
                        widget.shop.rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.location_on_rounded, color: AppColors.textLight, size: 20),
                      SizedBox(width: 4),
                      Text(
                        widget.shop.address,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchMaps,
                      icon: Icon(Icons.directions_rounded, color: Colors.white),
                      label: Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'All',
                          isSelected: selectedCategory == null,
                          onTap: () => setState(() => selectedCategory = null),
                        ),
                        ...categories.map((category) => _CategoryChip(
                          label: category,
                          isSelected: selectedCategory == category,
                          onTap: () => setState(() => selectedCategory = category),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = flatList[index];
                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  );
                } else if (item is ProductModel) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _ProductItem(product: item),
                    ),
                  );
                }
                return null;
              },
              childCount: flatList.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final ProductModel product;

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'product_${product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppColors.background,
                    child: Icon(Icons.image_not_supported_rounded, color: AppColors.textLight),
                  );
                },
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  product.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${product.price}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      SizedBox(width: 8),
                      Text(
                        '₹${product.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!product.inStock)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Out of Stock',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
            ),
        ],
      ),
    );
  }
}
