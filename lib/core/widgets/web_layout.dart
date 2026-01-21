import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../features/map_discovery/screens/search_screen.dart';
import '../../features/map_discovery/screens/cart_screen.dart';
import '../../features/map_discovery/screens/store_map_screen.dart';
import '../../features/customer_dashboard/stats_screen.dart';

class WebLayout extends StatefulWidget {
  final Widget homeContent;
  final Widget storesContent;
  final Widget dealsContent;
  final int initialIndex;
  
  const WebLayout({
    super.key, 
    required this.homeContent,
    required this.storesContent,
    required this.dealsContent,
    this.initialIndex = 0,
  });

  @override
  State<WebLayout> createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _WebNavbar(
            selectedIndex: _selectedIndex,
            onNavTap: _onNavTap,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                widget.homeContent,
                widget.storesContent,
                widget.dealsContent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavTap;

  const _WebNavbar({required this.selectedIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                errorBuilder: (c, e, s) => const Icon(Icons.shopping_basket, size: 40, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Text(
                'NEST',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 80),

          // Search Bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade500),
                    const SizedBox(width: 12),
                    Text(
                      'Search for products, brands and more...',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 60),

          // Navigation Links
          _NavBarItem(
            title: 'Home',
            icon: Icons.home_rounded,
            isSelected: selectedIndex == 0,
            onTap: () => onNavTap(0),
          ),
          const SizedBox(width: 24),
          _NavBarItem(
            title: 'Stores',
            icon: Icons.store_mall_directory_rounded,
            isSelected: selectedIndex == 1,
            onTap: () => onNavTap(1),
          ),
          const SizedBox(width: 24),
          _NavBarItem(
            title: 'Deals',
            icon: Icons.local_offer_rounded,
            isSelected: selectedIndex == 2,
            onTap: () => onNavTap(2),
          ),

          const SizedBox(width: 40),

          // Actions
          _ActionIcon(
            icon: Icons.map_outlined, 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreMapScreen()));
            },
          ),
          const SizedBox(width: 16),
          _ActionIcon(
            icon: Icons.shopping_cart_outlined, 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
          const SizedBox(width: 16),
          _ActionIcon(
            icon: Icons.person_outline, 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? AppColors.primary.withOpacity(0.1) 
                : _isHovered 
                    ? Colors.grey.shade100 
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: widget.isSelected ? AppColors.primary : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.primary.withOpacity(0.1) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _isHovered ? AppColors.primary : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(widget.icon, color: _isHovered ? AppColors.primary : AppColors.text, size: 22),
        ),
      ),
    );
  }
}

