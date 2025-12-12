import 'package:flutter/material.dart';
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

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
    );
  }
}

class _ModernBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _ModernBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.white.withOpacity(0.7),
              size: isSelected ? 26 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E3A5F),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textLight, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search for groceries, vegetables...',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.chevron_left_rounded, color: AppColors.text, size: 24),
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.chevron_right_rounded, color: AppColors.text, size: 24),
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
                        color: Colors.white,
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.text,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.brand} • ${product.unit}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${product.price}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: product.inStock 
                                          ? AppColors.primary.withOpacity(0.1) 
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                      color: product.inStock ? AppColors.primary : Colors.grey,
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
