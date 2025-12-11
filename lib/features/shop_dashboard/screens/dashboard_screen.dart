import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';

import 'inventory_screen.dart';
import 'billing_screen.dart';
import 'analytics_screen.dart';
import 'add_product_catalog_screen.dart';
import 'add_offer_screen.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  State<ShopOwnerDashboard> createState() => _ShopOwnerDashboardState();
}

class _ShopOwnerDashboardState extends State<ShopOwnerDashboard> {
  // Shop status is now managed by StoreProvider
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardHome(),
          const InventoryScreen(),
          const BillingScreen(),
          const AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.dashboard_rounded, 'Home', 0),
            _buildNavItem(Icons.inventory_2_rounded, 'Inventory', 1),
            _buildNavItem(Icons.receipt_long_rounded, 'Billing', 2),
            _buildNavItem(Icons.insights_rounded, 'Analytics', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.white.withOpacity(0.7),
              size: isSelected ? 24 : 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E3A5F),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStoreStatusCard(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 28),
              _buildQuickActions(),
              const SizedBox(height: 28),
              _buildRecentOrders(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final shopName = context.watch<StoreProvider>().loggedInShop?.name ?? 'My Store';
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shopName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Today's Sales", '₹12,450', Icons.trending_up_rounded),
                Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
                _buildSummaryItem('Orders', '28', Icons.shopping_bag_rounded),
                Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
                _buildSummaryItem('Customers', '23', Icons.people_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStoreStatusCard() {
    final storeProvider = context.watch<StoreProvider>();
    final shop = storeProvider.loggedInShop;
    final isOpen = shop?.isOpen ?? true;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isOpen 
            ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
            : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? const Color(0xFF10B981) : Colors.grey).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isOpen ? Icons.storefront_rounded : Icons.store_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOpen ? 'Store is Open' : 'Store is Closed',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOpen ? 'Accepting orders now' : 'Tap to go online',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ],
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: isOpen,
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              onChanged: (val) {
                context.read<StoreProvider>().toggleShopStatus(storeProvider.currentShopId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
                child: _buildStatCard(Icons.inventory_2_rounded, 'Products', '248', '+12 this week', const Color(0xFF6366F1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen(showLowStockOnly: true))),
                child: _buildStatCard(Icons.warning_amber_rounded, 'Low Stock', '8', 'Items running low', const Color(0xFFF59E0B)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLight)),
          const SizedBox(height: 4),
          Text(change, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionCard(Icons.add_box_rounded, 'Add Product', const Color(0xFF6366F1), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductCatalogScreen(
                onProductAdded: (newProduct, selectedSize, price) {
                  // Add to inventory
                  setState(() {
                      final shopId = context.read<StoreProvider>().currentShopId;
                      String productNameWithSize = '${newProduct.name} ($selectedSize)';
                      
                      // Check if exists
                      final index = mockProducts.indexWhere((p) => p.name == productNameWithSize && p.shopId == shopId);
                      
                      if (index == -1) {
                         final productToAdd = ProductModel(
                           id: DateTime.now().millisecondsSinceEpoch.toString(),
                           shopId: shopId,
                           name: productNameWithSize,
                           price: price,
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
                         mockProducts.add(productToAdd);
                         
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('${productToAdd.name} added to inventory!'), backgroundColor: Colors.green),
                         );
                      } else {
                         // Increment stock
                         final existing = mockProducts[index];
                         mockProducts[index] = ProductModel(
                           id: existing.id,
                           shopId: existing.shopId,
                           name: existing.name,
                           price: existing.price,
                           originalPrice: existing.originalPrice,
                           imageUrl: existing.imageUrl,
                           inStock: true,
                           stockQuantity: existing.stockQuantity + 1,
                           category: existing.category,
                           brand: existing.brand,
                           unit: existing.unit,
                         );
                         
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Product stock updated!'), backgroundColor: Colors.blue),
                         );
                      }
                  });
                },
              )));
            }),
            const SizedBox(width: 12),
            _buildActionCard(Icons.qr_code_scanner_rounded, 'Scan & Bill', const Color(0xFF10B981), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BillingScreen()));
            }),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionCard(Icons.edit_note_rounded, 'Update Stock', const Color(0xFFF59E0B), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
            }),
            const SizedBox(width: 12),
            _buildActionCard(Icons.local_offer_rounded, 'Add Offer', const Color(0xFFEF4444), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddOfferScreen()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        _buildOrderItem('#ORD-2847', 'Murugan', '₹458', '2 mins ago'),
        const SizedBox(height: 12),
        _buildOrderItem('#ORD-2846', 'Lakshmi', '₹1,245', '15 mins ago'),
        const SizedBox(height: 12),
        _buildOrderItem('#ORD-2845', 'Selvam', '₹789', '32 mins ago'),
      ],
    );
  }

  Widget _buildOrderItem(String orderId, String customer, String amount, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(customer, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
