import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../../core/providers/sales_provider.dart';

import 'inventory_screen.dart';
import 'billing_screen.dart';
import 'analytics_screen.dart';
import 'add_product_screen.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  State<ShopOwnerDashboard> createState() => _ShopOwnerDashboardState();
}

class _ShopOwnerDashboardState extends State<ShopOwnerDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWeb 
          ? Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: _buildCurrentPage(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildCurrentPage()),
                _buildBottomNav(),
              ],
            ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return const InventoryScreen();
      case 2:
        return const BillingScreen();
      case 3:
        return const AnalyticsScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const SizedBox(height: 20),
                _buildSidebarItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0),
                _buildSidebarItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Inventory', 1),
                _buildSidebarItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Billing', 2),
                _buildSidebarItem(Icons.insights_outlined, Icons.insights, 'Analytics', 3),
              ],
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    final shop = context.watch<StoreProvider>().loggedInShop;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_basket, color: Colors.white, size: 24),
          ),
          if (_isSidebarExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEST',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Vendor Portal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
              size: 24,
            ),
            if (_isSidebarExpanded) ...[
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => context.read<StoreProvider>().logout().then((_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              if (_isSidebarExpanded) ...[
                const SizedBox(width: 12),
                const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final shop = context.watch<StoreProvider>().loggedInShop;
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isSidebarExpanded ? Icons.menu_open : Icons.menu),
            onPressed: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
          ),
          const SizedBox(width: 16),
          Text(
            _getPageTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const Spacer(),
          _buildStoreStatusToggle(),
          const SizedBox(width: 24),
          _buildNotificationIcon(),
          const SizedBox(width: 16),
          _buildUserProfile(shop?.name ?? 'Account'),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard Overview';
      case 1: return 'Inventory Management';
      case 2: return 'Point of Sale (Billing)';
      case 3: return 'Business Analytics';
      default: return 'Dashboard';
    }
  }

  Widget _buildStoreStatusToggle() {
    final storeProvider = context.watch<StoreProvider>();
    final isOpen = storeProvider.loggedInShop?.isOpen ?? true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isOpen ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? 'Store Open' : 'Store Closed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isOpen ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isOpen,
              onChanged: (val) => storeProvider.toggleShopStatus(storeProvider.currentShopId),
              activeColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Icon(Icons.notifications_none_rounded, color: Colors.grey.shade600, size: 28),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile(String name) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Text('Administrator', style: TextStyle(color: AppColors.textLight, fontSize: 11)),
          ],
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildDashboardHome() {
    final isWeb = MediaQuery.of(context).size.width > 900;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetings(),
          const SizedBox(height: 32),
          _buildStatsSummary(),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildMainContent()),
              if (isWeb) ...[
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildSideInfoGrid()),
              ],
            ],
          ),
          if (!isWeb) ...[
            const SizedBox(height: 32),
            _buildSideInfoGrid(),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGreetings() {
    final shopName = context.watch<StoreProvider>().loggedInShop?.name ?? 'Store';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $shopName!',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is what is happening with your store today.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatsSummary() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        final shopId = context.read<StoreProvider>().currentShopId;
        final analytics = salesProvider.getTodayAnalytics(shopId);
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 48) / (MediaQuery.of(context).size.width > 1200 ? 4 : 2);
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSummaryCard('Total Revenue', '₹${analytics.totalRevenue.toStringAsFixed(0)}', Icons.payments_rounded, Colors.blue),
                _buildSummaryCard('Total Orders', analytics.totalTransactions.toString(), Icons.shopping_bag_rounded, Colors.orange),
                _buildSummaryCard('Items Sold', analytics.totalItemsSold.toString(), Icons.analytics_rounded, Colors.purple),
                _buildSummaryCard('Active Customers', '12', Icons.people_rounded, Colors.teal),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    return Container(
      width: isWeb ? 260 : (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recent Transactions', 'View All Sales History'),
        const SizedBox(height: 16),
        _buildRecentOrdersTable(),
        const SizedBox(height: 40),
        _buildSectionHeader('Quick Controls', null),
        const SizedBox(height: 16),
        _buildQuickActionsGrid(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
        if (actionText != null)
          TextButton(
            onPressed: () => setState(() => _selectedIndex = 3),
            child: Text(actionText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildRecentOrdersTable() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        final shopId = context.read<StoreProvider>().currentShopId;
        final txs = salesProvider.transactions.where((t) => t.shopId == shopId).toList();
        txs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final recent = txs.take(5).toList();

        if (recent.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: const Center(child: Text('No orders found yet.')),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              ...recent.map((tx) => _buildTableRow(tx)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('ORDER ID', style: _tableHeaderStyle())),
          Expanded(flex: 3, child: Text('CUSTOMER', style: _tableHeaderStyle())),
          Expanded(flex: 2, child: Text('AMOUNT', style: _tableHeaderStyle())),
          Expanded(flex: 2, child: Text('STATUS', style: _tableHeaderStyle())),
        ],
      ),
    );
  }

  TextStyle _tableHeaderStyle() => TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1);

  Widget _buildTableRow(SaleTransaction tx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('#${tx.id.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(tx.customerPhone ?? 'Direct Sale')),
          Expanded(flex: 2, child: Text('₹${tx.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Complete', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionTile(Icons.add_shopping_cart, 'Add Product', Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        }),
        _buildActionTile(Icons.receipt, 'Direct Billing', Colors.green, () {
          setState(() => _selectedIndex = 2);
        }),
        _buildActionTile(Icons.inventory, 'Stock Count', Colors.orange, () {
          setState(() => _selectedIndex = 1);
        }),
        _buildActionTile(Icons.local_offer, 'Create Offer', Colors.purple, () {}),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSideInfoGrid() {
    return Column(
      children: [
        _buildProfileCard(),
        const SizedBox(height: 24),
        _buildInventoryHealthCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    final shop = context.watch<StoreProvider>().loggedInShop;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(shop?.imageUrl ?? ''),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Text(shop?.name ?? 'Loading...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(shop?.category ?? 'Vendor', style: TextStyle(color: Colors.grey.shade500)),
          const Divider(height: 32),
          _buildProfileStat('Status', 'Verified', Colors.green),
          const SizedBox(height: 12),
          _buildProfileStat('Experience', 'Top Tier', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInventoryHealthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2D323E), Color(0xFF191C24)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Health', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildHealthIndicator('Stock Availability', 0.85, Colors.green),
          const SizedBox(height: 20),
          _buildHealthIndicator('Low Stock Alerts', 0.15, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('${(percent * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'POS'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights), label: 'Analytics'),
        ],
      ),
    );
  }
}
