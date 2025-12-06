import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import 'shop_details_view.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  String _query = '';
  List<ProductModel> _results = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _query = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _results = [];
    } else {
      final lowerQuery = query.toLowerCase();
      
      // Category mappings for better search
      final categoryMappings = {
        'vegetables': ['vegetables', 'vegetable', 'veggies'],
        'fruits': ['fruits', 'fruit', 'fresh fruits'],
        'dairy': ['dairy', 'milk', 'curd', 'paneer', 'cheese', 'butter', 'ghee'],
        'bakery': ['bakery', 'bread', 'biscuits', 'cookies'],
        'rice & atta': ['rice', 'atta', 'flour', 'grains', 'maida', 'rava'],
        'oil & ghee': ['oil', 'ghee', 'cooking oil'],
        'spices': ['spices', 'masala', 'turmeric', 'chilli', 'coriander'],
        'snacks': ['snacks', 'chips', 'namkeen', 'munchies', 'biscuits'],
        'beverages': ['beverages', 'drinks', 'juice', 'tea', 'coffee', 'cold drinks'],
        'tea & coffee': ['tea', 'coffee', 'beverages'],
        'instant food': ['instant', 'noodles', 'pasta', 'ready to eat'],
        'chocolates': ['chocolate', 'chocolates', 'candy', 'cocoa'],
        'ice cream': ['ice cream', 'frozen', 'dessert'],
        'eggs': ['eggs', 'egg'],
        'personal care': ['personal care', 'soap', 'shampoo', 'lotion'],
        'cleaning': ['cleaning', 'detergent', 'dish wash', 'floor cleaner', 'household'],
        'baby care': ['baby', 'diaper', 'infant'],
        'pet care': ['pet', 'dog food', 'cat food'],
      };
      
      // Check if query matches any category mapping
      List<String> searchTerms = [lowerQuery];
      for (var entry in categoryMappings.entries) {
        if (entry.key.contains(lowerQuery) || entry.value.any((v) => v.contains(lowerQuery))) {
          searchTerms.addAll(entry.value);
        }
      }
      
      _results = mockProducts.where((p) {
        final name = p.name.toLowerCase();
        final category = p.category.toLowerCase();
        final brand = p.brand.toLowerCase();
        
        return searchTerms.any((term) => 
          name.contains(term) || 
          category.contains(term) ||
          brand.contains(term)
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search for milk, bread, vegetables...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.search_rounded,
                              size: 48, color: AppColors.primary.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Start typing to search',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.textLight.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No results found for "$_query"',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final product = _results[index];
                          final shop = mockShops.firstWhere(
                            (s) => s.id == product.shopId,
                            orElse: () => mockShops.first,
                          );
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ProductResultCard(product: product, shop: shop),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final ProductModel product;
  final ShopModel shop;

  const _ProductResultCard({required this.product, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailsView(shop: shop),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                        child: const Icon(Icons.image_not_supported_rounded,
                            size: 24, color: AppColors.textLight),
                      );
                    },
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.store_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${product.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
