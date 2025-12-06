import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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

class _HomeView extends StatelessWidget {
  const _HomeView();


  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
          child: Column(
            children: [
              _ProductHorizontalList(
                title: 'Daily Essentials',
                products: mockProducts.where((p) => p.inStock && (p.category.contains('Rice') || p.category.contains('Oil') || p.category.contains('Atta'))).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Fresh Vegetables',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Vegetables')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Snacks & Munchies',
                products: mockProducts.where((p) => p.inStock && (p.category.contains('Snacks') || p.category.contains('Biscuits'))).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Cold Drinks & Juices',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Beverages')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Dairy & Breakfast',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Dairy')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Tea & Coffee',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Tea & Coffee')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Ice Cream & Frozen',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Ice Cream')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Chocolates & Sweets',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Chocolate')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Instant Food',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Instant')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Masala & Spices',
                products: mockProducts.where((p) => p.inStock && (p.category.contains('Masala') || p.category.contains('Spices'))).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Fresh Fruits',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Fruits')).take(10).toList(),
              ),
              _ProductHorizontalList(
                title: 'Cleaning & Household',
                products: mockProducts.where((p) => p.inStock && p.category.contains('Household')).take(10).toList(),
              ),
            ],
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
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

  final List<Map<String, dynamic>> banners = [
    {'gradient': [const Color(0xFF4CAF50), const Color(0xFF81C784)], 'title': 'Fresh Vegetables', 'subtitle': 'Up to 40% OFF', 'icon': '🥬', 'category': 'Vegetables'},
    {'gradient': [const Color(0xFFFF7043), const Color(0xFFFF8A65)], 'title': 'Instant Foods', 'subtitle': 'Buy 1 Get 1 Free', 'icon': '🍜', 'category': 'Noodles'},
    {'gradient': [const Color(0xFF42A5F5), const Color(0xFF64B5F6)], 'title': 'Summer Drinks', 'subtitle': 'Starting ₹29', 'icon': '🥤', 'category': 'Beverages'},
  ];

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
    return Column(
      children: [
        Container(
          height: 170,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: banners.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return _AnimatedBanner(
                    gradient: banner['gradient'] as List<Color>,
                    title: banner['title'] as String,
                    subtitle: banner['subtitle'] as String,
                    emoji: banner['icon'] as String,
                    category: banner['category'] as String,
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
              if (_currentPage < banners.length - 1)
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
          children: List.generate(banners.length, (index) {
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
  }
}

class _AnimatedBanner extends StatelessWidget {
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String emoji;
  final String category;

  const _AnimatedBanner({
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCategory(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(20),
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _navigateToCategory(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            'Shop Now',
                            style: TextStyle(
                              color: gradient.first,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: gradient.first, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(emoji, style: const TextStyle(fontSize: 60)),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context) {
    // Navigate to first store with the category pre-selected
    if (mockShops.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShopDetailsView(shop: mockShops.first),
        ),
      );
    }
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
                        builder: (context) => ShopDetailsView(shop: shop),
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
