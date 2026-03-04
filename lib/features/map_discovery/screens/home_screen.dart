import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../models/shop_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'shop_details_view.dart';
import 'search_screen.dart';
import 'offers_screen.dart';
import 'stores_list_screen.dart';

import 'package:flutter/foundation.dart';
import '../../../core/widgets/web_layout.dart';
import '../../customer_dashboard/stats_screen.dart';

import '../../../core/providers/theme_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && MediaQuery.of(context).size.width > 900) {
      return WebLayout(
        initialIndex: 0,
        homeContent: const _WebHomeView(),
        storesContent: const _WebStoresView(),
        dealsContent: const _WebDealsView(),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
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

        // 3. Transparent Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _HomeView(),
                StoresListScreen(),
                OffersScreen(),
              ],
            ),
          ),
          bottomNavigationBar: _ModernBottomNav(
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ],
    );
  }
}

class _ModernBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _ModernBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(32),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FloatingNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _FloatingNavItem(
                  icon: Icons.store_mall_directory_rounded,
                  label: 'Stores',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _FloatingNavItem(
                  icon: Icons.local_offer_rounded,
                  label: 'Deals',
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                  badge: 'HOT',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTextColor = isDark ? Colors.white : const Color(0xFF1E3A5F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF2A2A2A) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedTextColor : Colors.white.withOpacity(0.7),
              size: isSelected ? 26 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selectedTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
            if (badge != null && !isSelected)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  List<ProductModel> _allProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _allProducts = snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductModel(
              id: data['id'] ?? doc.id,
              shopId: data['shopId'] ?? '',
              name: data['name'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
              imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/300',
              inStock: data['inStock'] ?? true,
              stockQuantity: data['stockQuantity'] ?? 0,
              category: data['category'] ?? 'Other',
              brand: data['brand'] ?? 'Local',
              unit: data['unit'] ?? 'weight',
            );
          }).where((p) => p.inStock).toList();
          _isLoading = false;
        });
        debugPrint('Loaded ${_allProducts.length} products from Firestore for customer view');
      } else {
        // Fallback to mock products
        setState(() {
          _allProducts = mockProducts;
          _isLoading = false;
        });
        debugPrint('Using ${mockProducts.length} mock products as fallback');
      }
    } catch (e) {
      debugPrint('Error loading products for customer: $e');
      setState(() {
        _allProducts = mockProducts;
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Modern App Bar
          SliverToBoxAdapter(child: _ModernHeader()),
          
          // Promotional Banners
          SliverToBoxAdapter(child: _PromotionalBanners()),
          
          // Categories Section
          // Category Buttons with Scroll Arrows
          const SliverToBoxAdapter(
            child: _CategoryScrollSection(),
          ),
          
          // Essential Products Sections
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                // Get list of open shop IDs
                final openShopIds = context.watch<StoreProvider>()
                    .shops
                    .where((shop) => shop.isOpen)
                    .map((shop) => shop.id)
                    .toSet();
                
                // Filter products from open shops only - use _allProducts from Firestore
                final availableProducts = _allProducts
                    .where((p) => p.inStock && openShopIds.contains(p.shopId))
                    .toList();
                
                if (_isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (availableProducts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textLight),
                          const SizedBox(height: 16),
                          const Text(
                            'No products available yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Shops will add their products soon!',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadProducts,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: [
                    _ProductHorizontalList(
                      title: 'Daily Essentials',
                      products: (availableProducts.where((p) => (p.category.contains('Rice') || p.category.contains('Oil') || p.category.contains('Atta'))).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Fresh Vegetables',
                      products: (availableProducts.where((p) => p.category.contains('Vegetables')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Snacks & Munchies',
                      products: (availableProducts.where((p) => (p.category.contains('Snacks') || p.category.contains('Biscuits'))).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Cold Drinks & Juices',
                      products: (availableProducts.where((p) => p.category.contains('Beverages')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Dairy & Breakfast',
                      products: (availableProducts.where((p) => p.category.contains('Dairy')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Tea & Coffee',
                      products: (availableProducts.where((p) => p.category.contains('Tea & Coffee')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Ice Cream & Frozen',
                      products: (availableProducts.where((p) => p.category.contains('Ice Cream')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Chocolates & Sweets',
                      products: (availableProducts.where((p) => p.category.contains('Chocolate')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Instant Food',
                      products: (availableProducts.where((p) => p.category.contains('Instant')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Masala & Spices',
                      products: (availableProducts.where((p) => (p.category.contains('Masala') || p.category.contains('Spices'))).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Fresh Fruits',
                      products: (availableProducts.where((p) => p.category.contains('Fruits')).toList()..shuffle()).take(10).toList(),
                    ),
                    _ProductHorizontalList(
                      title: 'Cleaning & Household',
                      products: (availableProducts.where((p) => p.category.contains('Household')).toList()..shuffle()).take(10).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ModernHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Top Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'Thillai Nagar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.8)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trichy, Tamil Nadu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final isDark = themeProvider.isDarkMode;
                  return GestureDetector(
                    onTap: () => themeProvider.toggleTheme(!isDark),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: Colors.white, 
                        size: 22
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar - Tappable
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Theme.of(context).textTheme.bodySmall?.color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search for groceries, vegetables...',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: AppColors.border,
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.mic_rounded, color: AppColors.primary, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionalBanners extends StatefulWidget {
  @override
  State<_PromotionalBanners> createState() => _PromotionalBannersState();
}

class _PromotionalBannersState extends State<_PromotionalBanners> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  // Color gradients for banners (will cycle through these)
  final List<List<Color>> bannerGradients = [
    [const Color(0xFF4CAF50), const Color(0xFF81C784)],
    [const Color(0xFFFF7043), const Color(0xFFFF8A65)],
    [const Color(0xFF42A5F5), const Color(0xFF64B5F6)],
    [const Color(0xFFAB47BC), const Color(0xFFBA68C8)],
    [const Color(0xFFEC407A), const Color(0xFFF06292)],
    [const Color(0xFFFFCA28), const Color(0xFFFFD54F)],
    [const Color(0xFF26A69A), const Color(0xFF4DB6AC)],
    [const Color(0xFFEF5350), const Color(0xFFE57373)],
  ];
  
  // Emojis for banners (will cycle through these)
  final List<String> bannerEmojis = ['🥬', '🛒', '🛍️', '🏪', '🍎', '🥕', '🍞', '🥛'];

  void _scrollToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, _) {
        final shops = storeProvider.shops;
        
        if (shops.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
      children: [
        Container(
          height: 120,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: shops.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  // Cycle through colors and emojis
                  final gradient = bannerGradients[index % bannerGradients.length];
                  final emoji = bannerEmojis[index % bannerEmojis.length];
                  
                  return _AnimatedBanner(
                    gradient: gradient,
                    title: shop.name,
                    subtitle: shop.category,
                    emoji: emoji,
                    shopId: shop.id,
                  );
                },
              ),
              // Left Arrow
              if (_currentPage > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _scrollToPage(_currentPage - 1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                          ],
                        ),
                        child: Icon(Icons.chevron_left_rounded, color: Theme.of(context).iconTheme.color, size: 24),
                      ),
                    ),
                  ),
                ),
              // Right Arrow
              if (_currentPage < shops.length - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _scrollToPage(_currentPage + 1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                          ],
                        ),
                        child: Icon(Icons.chevron_right_rounded, color: Theme.of(context).iconTheme.color, size: 24),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(shops.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
      },
    );
  }
}

class _AnimatedBanner extends StatelessWidget {
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String emoji;
  final String shopId;

  const _AnimatedBanner({
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.shopId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCategory(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Reduced margin
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Further reduced padding
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced from 8
                  GestureDetector(
                    onTap: () => _navigateToCategory(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced button padding
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Visit Store',
                            style: TextStyle(
                              color: gradient.first,
                              fontWeight: FontWeight.w700,
                              fontSize: 12, // Reduced from 13
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: gradient.first, size: 14), // Reduced from 16
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(emoji, style: const TextStyle(fontSize: 50)),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context) {
    // Navigate to specific shop
    final storeProvider = context.read<StoreProvider>();
    final shop = storeProvider.shops.firstWhere(
      (s) => s.id == shopId,
      orElse: () => storeProvider.shops.isNotEmpty ? storeProvider.shops.first : mockShops.first,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopDetailsView(shop: shop),
      ),
    );
  }
}

class _CategoryScrollSection extends StatefulWidget {
  const _CategoryScrollSection();

  @override
  State<_CategoryScrollSection> createState() => _CategoryScrollSectionState();
}

class _CategoryScrollSectionState extends State<_CategoryScrollSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 10;
      _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with arrows
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              Row(
                children: [
                  if (_showLeftArrow)
                    GestureDetector(
                      onTap: _scrollLeft,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                  if (_showRightArrow)
                    GestureDetector(
                      onTap: _scrollRight,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Category buttons
        SizedBox(
          height: 45,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: mockCategories.length,
            itemBuilder: (context, index) {
              return _CategoryButton(category: mockCategories[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final CategoryModel category;

  const _CategoryButton({required this.category});

  Color _getCategoryColor(String name) {
    final colors = {
      'Vegetables': const Color(0xFFE8F5E9),
      'Fruits': const Color(0xFFFFF3E0),
      'Dairy': const Color(0xFFE3F2FD),
      'Bakery': const Color(0xFFFFF8E1),
      'Rice & Atta': const Color(0xFFFFF3E0),
      'Oil & Ghee': const Color(0xFFFFFDE7),
      'Spices': const Color(0xFFFFEBEE),
      'Snacks': const Color(0xFFFFF8E1),
      'Beverages': const Color(0xFFE0F7FA),
      'Tea & Coffee': const Color(0xFFEFEBE9),
      'Instant Food': const Color(0xFFFCE4EC),
      'Chocolates': const Color(0xFFEFEBE9),
      'Ice Cream': const Color(0xFFE1F5FE),
      'Eggs': const Color(0xFFFFF8E1),
      'Personal Care': const Color(0xFFF3E5F5),
      'Cleaning': const Color(0xFFE0F2F1),
      'Baby Care': const Color(0xFFFCE4EC),
      'Pet Care': const Color(0xFFE8F5E9),
    };
    return colors[name] ?? const Color(0xFFF3F4F6);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialQuery: category.name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _getCategoryColor(category.name),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Image.network(
                category.imageUrl,
                errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 18, color: AppColors.textLight),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHorizontalList extends StatefulWidget {
  final String title;
  final List<ProductModel> products;

  const _ProductHorizontalList({required this.title, required this.products});

  @override
  State<_ProductHorizontalList> createState() => _ProductHorizontalListState();
}

class _ProductHorizontalListState extends State<_ProductHorizontalList> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 10;
      _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
              ),
              Row(
                children: [
                  if (_showLeftArrow)
                    GestureDetector(
                      onTap: _scrollLeft,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                  if (_showRightArrow)
                    GestureDetector(
                      onTap: _scrollRight,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the store that has this product
                    final shop = mockShops.firstWhere(
                      (s) => s.id == product.shopId,
                      orElse: () => mockShops.first,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopDetailsView(
                          shop: shop,
                          initialProduct: product,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Theme.of(context).cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : AppColors.border.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Stack(
                              children: [
                                Image.network(
                                  product.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.background,
                                    child: Center(
                                      child: Icon(Icons.shopping_basket, 
                                        color: AppColors.textLight.withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                                if (!product.inStock)
                                  Container(
                                    color: Colors.white.withOpacity(0.8),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[800],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Out of Stock',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? AppColors.textDark : AppColors.text,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.brand} • ${product.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textLightDark : AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${product.price}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: isDark ? AppColors.textDark : AppColors.text,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: product.inStock 
                                          ? AppColors.primary.withOpacity(0.1) 
                                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                      color: product.inStock ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WebHomeView extends StatefulWidget {
  const _WebHomeView();

  @override
  State<_WebHomeView> createState() => _WebHomeViewState();
}

class _WebHomeViewState extends State<_WebHomeView> {
  List<ProductModel> _allProducts = [];
  bool _isLoading = true;
  final ScrollController _storesScrollController = ScrollController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex++;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _storesScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _allProducts = snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductModel(
              id: data['id'] ?? doc.id,
              shopId: data['shopId'] ?? '',
              name: data['name'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
              imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/300',
              inStock: data['inStock'] ?? true,
              stockQuantity: data['stockQuantity'] ?? 0,
              category: data['category'] ?? 'Other',
              brand: data['brand'] ?? 'Local',
              unit: data['unit'] ?? 'weight',
            );
          }).where((p) => p.inStock).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _allProducts = mockProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products for customer: $e');
      setState(() {
        _allProducts = mockProducts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final shops = context.watch<StoreProvider>().shops;
    final openShopIds = shops
        .where((shop) => shop.isOpen)
        .map((shop) => shop.id)
        .toSet();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final availableProducts = _allProducts
        .where((p) => p.inStock && openShopIds.contains(p.shopId))
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Random Ad Banner
              if (availableProducts.isNotEmpty)
                Builder(
                  builder: (context) {
                    final product = availableProducts[_currentBannerIndex % availableProducts.length];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: ClipRRect(
                        key: ValueKey<String>(product.id),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 340,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: isDark 
                                  ? [const Color(0xFF1E3A5F), const Color(0xFF2D5A87)]
                                  : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? const Color(0xFF1E3A5F).withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Opacity(
                                  opacity: 0.15,
                                  child: Image.network(
                                    product.imageUrl,
                                    height: 350,
                                    width: 350,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.shopping_bag, size: 350, color: Colors.white.withOpacity(0.05)),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 30,
                                top: 40,
                                bottom: 40,
                                child: Hero(
                                  tag: 'product_banner_${product.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      product.imageUrl,
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            height: 200,
                                            width: 200,
                                            color: Colors.white24,
                                            child: const Icon(Icons.shopping_bag, size: 64, color: Colors.white),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'HOT DEAL',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 500,
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Only ₹${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(color: Colors.yellowAccent[100], fontSize: 24, fontWeight: FontWeight.w600),
                                    ),
                                    if (product.originalPrice != null)
                                      Text(
                                        'Was ₹${product.originalPrice!.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        // You could add navigation to product details here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Shop Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              
              const SizedBox(height: 48),
              
              // Trending Stores Section
              Row(
                children: [
                  Text(
                    'Trending Stores',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.text),
                  ),
                  const Spacer(),
                  _ScrollArrowButton(
                    icon: Icons.arrow_back_ios_rounded,
                    onTap: () => _storesScrollController.animateTo(
                      _storesScrollController.offset - 340,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ScrollArrowButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: () => _storesScrollController.animateTo(
                      _storesScrollController.offset + 340,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  controller: _storesScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: shops.where((s) => s.isOpen).take(6).length,
                  itemBuilder: (context, index) {
                    final shop = shops.where((s) => s.isOpen).toList()[index];
                    final shopProducts = _allProducts.where((p) => p.shopId == shop.id).take(3).toList();
                    return _WebStoreCard(shop: shop, trendingProducts: shopProducts);
                  },
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Categories Grid
              Text(
                'Shop by Category',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.text),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 6,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: const [
                  _WebCategoryCard(title: 'Vegetables', icon: '🥕', color: Colors.green),
                  _WebCategoryCard(title: 'Fruits', icon: '🍎', color: Colors.red),
                  _WebCategoryCard(title: 'Dairy', icon: '🥛', color: Colors.blue),
                  _WebCategoryCard(title: 'Bakery', icon: '🍞', color: Colors.brown),
                  _WebCategoryCard(title: 'Beverages', icon: '🥤', color: Colors.orange),
                  _WebCategoryCard(title: 'Household', icon: '🧹', color: Colors.purple),
                  _WebCategoryCard(title: 'Rice & Atta', icon: '🌾', color: Colors.amber),
                  _WebCategoryCard(title: 'Oil & Ghee', icon: '🫒', color: Colors.lime),
                  _WebCategoryCard(title: 'Spices', icon: '🌶️', color: Colors.deepOrange),
                  _WebCategoryCard(title: 'Snacks', icon: '🍿', color: Colors.pink),
                  _WebCategoryCard(title: 'Tea & Coffee', icon: '☕', color: Colors.brown),
                  _WebCategoryCard(title: 'Personal Care', icon: '🧴', color: Colors.teal),
                ],
              ),
              
              const SizedBox(height: 64),
              
              // Daily Essentials
              _WebProductSection(
                title: 'Daily Essentials',
                products: (availableProducts.where((p) => (p.category.contains('Rice') || p.category.contains('Oil') || p.category.contains('Atta'))).toList()..shuffle()).take(10).toList(),
              ),

              const SizedBox(height: 48),

              // Fresh Vegetables
              _WebProductSection(
                title: 'Fresh Vegetables', 
                products: (availableProducts.where((p) => p.category.contains('Vegetables')).toList()..shuffle()).take(10).toList(),
              ),
              
              const SizedBox(height: 48),
              
              // Fruits
              _WebProductSection(
                title: 'Fresh Fruits', 
                products: (availableProducts.where((p) => p.category.contains('Fruits')).toList()..shuffle()).take(10).toList(),
              ),
              
              const SizedBox(height: 48),
              
              // Dairy Products
              _WebProductSection(
                title: 'Dairy & Milk Products', 
                products: (availableProducts.where((p) => p.category.contains('Dairy')).toList()..shuffle()).take(10).toList(),
              ),
              
              const SizedBox(height: 48),
              
              // Snacks
              _WebProductSection(
                title: 'Snacks & Munchies', 
                products: (availableProducts.where((p) => p.category.contains('Snacks')).toList()..shuffle()).take(10).toList(),
              ),
              
              const SizedBox(height: 48),
              
              // Spices
              _WebProductSection(
                title: 'Spices & Masalas', 
                products: (availableProducts.where((p) => p.category.contains('Spices')).toList()..shuffle()).take(10).toList(),
              ),
              
              const SizedBox(height: 100),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text('NEST', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                         const SizedBox(height: 8),
                         Text('The smarter way to shop locally.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      ],
                    ),
                    const Spacer(),
                     Text('© 2026 NEST Inc.', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebCategoryCard extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;

  const _WebCategoryCard({required this.title, required this.icon, required this.color});

  @override
  State<_WebCategoryCard> createState() => _WebCategoryCardState();
}

class _WebCategoryCardState extends State<_WebCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(initialQuery: widget.title),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovered ? widget.color : (isDark ? Colors.white12 : Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isHovered ? 0.1 : 0),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? widget.color : (isDark ? AppColors.textDark : AppColors.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const _WebProductSection({required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.text),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('View All', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.textDark : AppColors.text)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.62,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _WebProductCard(product: product);
          },
        ),
      ],
    );
  }
}

class _WebProductCard extends StatefulWidget {
  final ProductModel product;

  const _WebProductCard({required this.product});

  @override
  State<_WebProductCard> createState() => _WebProductCardState();
}

class _WebProductCardState extends State<_WebProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Find the shop that has this product
          final shop = mockShops.firstWhere(
            (s) => s.id == widget.product.shopId,
            orElse: () => mockShops.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailsView(
                shop: shop,
                initialProduct: widget.product,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovered ? AppColors.primary : (isDark ? Colors.white10 : Colors.transparent)),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              else
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        image: DecorationImage(
                          image: NetworkImage(widget.product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (widget.product.originalPrice != null && widget.product.originalPrice! > widget.product.price)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            '${((1 - widget.product.price / widget.product.originalPrice!) * 100).round()}% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.brand.toUpperCase(),
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3, color: isDark ? AppColors.textDark : AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.product.stockQuantity} ${widget.product.unit}',
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${widget.product.price.toStringAsFixed(0)}',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? AppColors.textDark : AppColors.text),
                              ),
                              if (widget.product.originalPrice != null)
                                Text(
                                  '₹${widget.product.originalPrice!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
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

// Store card showing trending products
class _WebStoreCard extends StatefulWidget {
  final ShopModel shop;
  final List<ProductModel> trendingProducts;

  const _WebStoreCard({required this.shop, required this.trendingProducts});

  @override
  State<_WebStoreCard> createState() => _WebStoreCardState();
}

class _WebStoreCardState extends State<_WebStoreCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsView(shop: widget.shop)));
        },
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 320,
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).cardColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isHovered ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered ? AppColors.primary.withOpacity(0.1) : Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.shop.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.store, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.shop.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textDark : AppColors.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(widget.shop.rating.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textDark : AppColors.text)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Open', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Trending Products', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : AppColors.textLight)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: widget.trendingProducts.isEmpty
                          ? [Text('No products', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 12))]
                          : widget.trendingProducts.map((p) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(p.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Web Stores View
class _WebStoresView extends StatelessWidget {
  const _WebStoresView();

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<StoreProvider>().shops;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Stores',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              Text(
                '${shops.length} stores available near you',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return _WebStoreGridCard(shop: shop);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebStoreGridCard extends StatefulWidget {
  final ShopModel shop;

  const _WebStoreGridCard({required this.shop});

  @override
  State<_WebStoreGridCard> createState() => _WebStoreGridCardState();
}

class _WebStoreGridCardState extends State<_WebStoreGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsView(shop: widget.shop)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _isHovered ? AppColors.primary : (isDark ? Colors.white10 : Colors.transparent)),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? AppColors.primary.withOpacity(0.1) : Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.shop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.store, size: 48, color: AppColors.primary),
                        ),
                      ),
                      if (!widget.shop.isOpen)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Text('CLOSED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.shop.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.shop.address,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(widget.shop.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Web Deals View
class _WebDealsView extends StatelessWidget {
  const _WebDealsView();

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<StoreProvider>().shops;
    
    // Create sample offers based on shops
    final allOffers = <Map<String, dynamic>>[];
    final sampleOffers = [
      '20% OFF on Fresh Vegetables',
      'Buy 2 Get 1 Free on Dairy',
      'Flat ₹50 OFF on orders above ₹500',
      '15% OFF on Rice & Atta',
      'Free Delivery on orders above ₹300',
      '10% Cashback on first order',
    ];
    
    for (int i = 0; i < shops.length && i < sampleOffers.length; i++) {
      allOffers.add({
        'offer': sampleOffers[i],
        'shop': shops[i],
      });
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hot Deals & Offers',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              Text(
                '${allOffers.length} offers available right now',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (allOffers.isEmpty)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No offers available', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Check back later for exciting deals!', style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: allOffers.length,
                  itemBuilder: (context, index) {
                    final item = allOffers[index];
                    return _WebOfferCard(
                      offer: item['offer'] as String,
                      shop: item['shop'] as ShopModel,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebOfferCard extends StatefulWidget {
  final String offer;
  final ShopModel shop;

  const _WebOfferCard({required this.offer, required this.shop});

  @override
  State<_WebOfferCard> createState() => _WebOfferCardState();
}

class _WebOfferCardState extends State<_WebOfferCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsView(shop: widget.shop)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered 
                  ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                  : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (_isHovered ? AppColors.primary : const Color(0xFF667EEA)).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.offer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'at ${widget.shop.name}',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Scroll Arrow Button for horizontal lists
class _ScrollArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScrollArrowButton({required this.icon, required this.onTap});

  @override
  State<_ScrollArrowButton> createState() => _ScrollArrowButtonState();
}

class _ScrollArrowButtonState extends State<_ScrollArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isHovered ? AppColors.primary : Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? AppColors.primary.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _isHovered ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}
