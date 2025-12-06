import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../../core/providers/sales_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasGeneratedDemoData = false;
  
  // Selected dates for custom filtering
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateDemoData() {
    final salesProvider = context.read<SalesProvider>();
    final shopId = context.read<StoreProvider>().currentShopId;
    salesProvider.addDemoData(shopId);
    setState(() => _hasGeneratedDemoData = true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectWeek(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select any day in the week',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Get the Monday of that week
      final weekStart = picked.subtract(Duration(days: picked.weekday - 1));
      setState(() => _selectedWeekStart = weekStart);
    }
  }

  void _selectMonth(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: [
              // Year selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() => _selectedYear--);
                      Navigator.pop(context);
                      _selectMonth(context);
                    },
                  ),
                  Text(
                    '$_selectedYear',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _selectedYear < DateTime.now().year ? () {
                      setState(() => _selectedYear++);
                      Navigator.pop(context);
                      _selectMonth(context);
                    } : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Month grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isCurrentMonth = month == DateTime.now().month && _selectedYear == DateTime.now().year;
                    final isSelected = month == _selectedMonth && _selectedYear == _selectedYear;
                    final isFuture = _selectedYear == DateTime.now().year && month > DateTime.now().month;
                    
                    return GestureDetector(
                      onTap: isFuture ? null : () {
                        setState(() => _selectedMonth = month);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : (isCurrentMonth ? AppColors.primary.withOpacity(0.1) : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFuture ? Colors.grey.shade300 : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getMonthName(month),
                            style: TextStyle(
                              color: isFuture ? Colors.grey : (isSelected ? Colors.white : AppColors.text),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectYear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: 250,
          height: 300,
          child: ListView.builder(
            itemCount: DateTime.now().year - 2019,
            itemBuilder: (context, index) {
              final year = DateTime.now().year - index;
              final isSelected = year == _selectedYear;
              
              return ListTile(
                title: Text(
                  '$year',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.text,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedYear = year);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getFullMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final shopId = context.read<StoreProvider>().currentShopId;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Analytics & Reports', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          if (!_hasGeneratedDemoData && salesProvider.transactions.isEmpty)
            TextButton.icon(
              onPressed: _generateDemoData,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Demo Data'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Today', icon: Icon(Icons.today, size: 18)),
            Tab(text: 'Week', icon: Icon(Icons.date_range, size: 18)),
            Tab(text: 'Month', icon: Icon(Icons.calendar_month, size: 18)),
            Tab(text: 'Year', icon: Icon(Icons.calendar_today, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Today Tab
          _AnalyticsTabWithFilter(
            analytics: salesProvider.getTodayAnalytics(shopId),
            periodLabel: _formatDateLabel(_selectedDate),
            dailyData: salesProvider.getDailyRevenueData(shopId),
            topProducts: salesProvider.getTopProducts(shopId),
            topBrands: salesProvider.getTopBrands(shopId),
            filterWidget: _buildDateFilter(
              label: _formatDateLabel(_selectedDate),
              onTap: () => _selectDate(context),
              icon: Icons.calendar_today,
            ),
          ),
          // Week Tab
          _AnalyticsTabWithFilter(
            analytics: salesProvider.getWeekAnalytics(shopId),
            periodLabel: _formatWeekLabel(_selectedWeekStart),
            dailyData: salesProvider.getDailyRevenueData(shopId),
            topProducts: salesProvider.getTopProducts(shopId),
            topBrands: salesProvider.getTopBrands(shopId),
            filterWidget: _buildDateFilter(
              label: _formatWeekLabel(_selectedWeekStart),
              onTap: () => _selectWeek(context),
              icon: Icons.date_range,
            ),
          ),
          // Month Tab
          _AnalyticsTabWithFilter(
            analytics: salesProvider.getMonthAnalytics(shopId),
            periodLabel: '${_getFullMonthName(_selectedMonth)} $_selectedYear',
            dailyData: salesProvider.getDailyRevenueData(shopId),
            topProducts: salesProvider.getTopProducts(shopId),
            topBrands: salesProvider.getTopBrands(shopId),
            filterWidget: _buildDateFilter(
              label: '${_getFullMonthName(_selectedMonth)} $_selectedYear',
              onTap: () => _selectMonth(context),
              icon: Icons.calendar_month,
            ),
          ),
          // Year Tab
          _AnalyticsTabWithFilter(
            analytics: salesProvider.getYearAnalytics(shopId),
            periodLabel: '$_selectedYear',
            dailyData: salesProvider.getDailyRevenueData(shopId),
            topProducts: salesProvider.getTopProducts(shopId),
            topBrands: salesProvider.getTopBrands(shopId),
            filterWidget: _buildDateFilter(
              label: '$_selectedYear',
              onTap: () => _selectYear(context),
              icon: Icons.calendar_today,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _formatWeekLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day} ${_getMonthName(weekStart.month)} - ${weekEnd.day} ${_getMonthName(weekEnd.month)}';
  }

  Widget _buildDateFilter({required String label, required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTabWithFilter extends StatelessWidget {
  final AnalyticsSummary analytics;
  final String periodLabel;
  final List<Map<String, dynamic>> dailyData;
  final List<MapEntry<String, int>> topProducts;
  final List<MapEntry<String, double>> topBrands;
  final Widget filterWidget;

  const _AnalyticsTabWithFilter({
    required this.analytics,
    required this.periodLabel,
    required this.dailyData,
    required this.topProducts,
    required this.topBrands,
    required this.filterWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filter
          filterWidget,
          
          // Analytics Content
          _AnalyticsContent(
            analytics: analytics,
            periodLabel: periodLabel,
            dailyData: dailyData,
            topProducts: topProducts,
            topBrands: topBrands,
          ),
        ],
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final AnalyticsSummary analytics;
  final String periodLabel;
  final List<Map<String, dynamic>> dailyData;
  final List<MapEntry<String, int>> topProducts;
  final List<MapEntry<String, double>> topBrands;

  const _AnalyticsContent({
    required this.analytics,
    required this.periodLabel,
    required this.dailyData,
    required this.topProducts,
    required this.topBrands,
  });

  @override
  Widget build(BuildContext context) {
    final profitMargin = analytics.totalRevenue > 0 
        ? (analytics.totalProfit / analytics.totalRevenue * 100) 
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Revenue',
                value: '₹${_formatNumber(analytics.totalRevenue)}',
                subtitle: periodLabel,
                icon: Icons.currency_rupee,
                color: Colors.green,
                gradient: [Colors.green[400]!, Colors.green[600]!],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Profit',
                value: '₹${_formatNumber(analytics.totalProfit)}',
                subtitle: '${profitMargin.toStringAsFixed(1)}% margin',
                icon: Icons.trending_up,
                color: Colors.blue,
                gradient: [Colors.blue[400]!, Colors.blue[600]!],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Transactions',
                value: '${analytics.totalTransactions}',
                subtitle: 'bills generated',
                icon: Icons.receipt_long,
                color: Colors.orange,
                gradient: [Colors.orange[400]!, Colors.orange[600]!],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Items Sold',
                value: '${analytics.totalItemsSold}',
                subtitle: 'units',
                icon: Icons.shopping_basket,
                color: Colors.purple,
                gradient: [Colors.purple[400]!, Colors.purple[600]!],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Weekly Revenue Chart
        if (dailyData.isNotEmpty) ...[
          const _SectionHeader(title: 'Daily Revenue', subtitle: 'Last 7 days'),
          const SizedBox(height: 12),
          _RevenueChart(data: dailyData),
          const SizedBox(height: 24),
        ],
        
        // Revenue by Category
        if (analytics.revenueByCategory.isNotEmpty) ...[
          const _SectionHeader(title: 'Revenue by Category'),
          const SizedBox(height: 12),
          _CategoryBreakdown(data: analytics.revenueByCategory, total: analytics.totalRevenue),
          const SizedBox(height: 24),
        ],
        
        // Top Selling Products
        if (topProducts.isNotEmpty) ...[
          const _SectionHeader(title: 'Top Selling Products', subtitle: 'By quantity'),
          const SizedBox(height: 12),
          _TopProductsList(products: topProducts),
          const SizedBox(height: 24),
        ],
        
        // Top Brands
        if (topBrands.isNotEmpty) ...[
          const _SectionHeader(title: 'Top Brands', subtitle: 'By revenue'),
          const SizedBox(height: 12),
          _TopBrandsList(brands: topBrands),
          const SizedBox(height: 24),
        ],
        
        // Category-wise Sales with Top 3 Brands
        if (analytics.brandsByCategory.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Sales by Category', 
            subtitle: 'Top 3 brands per category',
          ),
          const SizedBox(height: 12),
          _CategoryBrandBreakdown(
            salesByCategory: analytics.salesByCategory,
            brandsByCategory: analytics.brandsByCategory,
            revenueBrandsByCategory: analytics.revenueBrandsByCategory,
            revenueByCategory: analytics.revenueByCategory,
          ),
          const SizedBox(height: 24),
        ],
        
        // Recent Transactions
        if (analytics.transactions.isNotEmpty) ...[
          _SectionHeader(
            title: 'Recent Transactions',
            subtitle: '${analytics.transactions.length} transactions',
          ),
          const SizedBox(height: 12),
          _TransactionsList(transactions: analytics.transactions.take(10).toList()),
        ],
        
        // Empty State
        if (analytics.totalTransactions == 0)
          _EmptyState(),
          
        const SizedBox(height: 100),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

// Keep the old _AnalyticsTab for compatibility
class _AnalyticsTab extends StatelessWidget {
  final AnalyticsSummary analytics;
  final String periodLabel;
  final List<Map<String, dynamic>> dailyData;
  final List<MapEntry<String, int>> topProducts;
  final List<MapEntry<String, double>> topBrands;

  const _AnalyticsTab({
    required this.analytics,
    required this.periodLabel,
    required this.dailyData,
    required this.topProducts,
    required this.topBrands,
  });

  @override
  Widget build(BuildContext context) {
    return _AnalyticsContent(
      analytics: analytics,
      periodLabel: periodLabel,
      dailyData: dailyData,
      topProducts: topProducts,
      topBrands: topBrands,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(subtitle!, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        ],
      ],
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = data.fold(0.0, (max, item) => 
        (item['revenue'] as double) > max ? item['revenue'] as double : max);

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final revenue = item['revenue'] as double;
                final heightPercent = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
                final isToday = item['day'] == _getDayName(DateTime.now().weekday);
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (revenue > 0)
                      Text(
                        '₹${(revenue / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 9, color: AppColors.textLight),
                      ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 28,
                      height: 80 * heightPercent + 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday 
                              ? [AppColors.primary, AppColors.primary.withOpacity(0.7)]
                              : [Colors.grey[400]!, Colors.grey[300]!],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.map((item) {
              final isToday = item['day'] == _getDayName(DateTime.now().weekday);
              return Text(
                item['day'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? AppColors.primary : AppColors.textLight,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> data;
  final double total;

  const _CategoryBreakdown({required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final sortedData = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
      Colors.pink[400]!,
      Colors.indigo[400]!,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Progress bars
          ...sortedData.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final percent = total > 0 ? (item.value / total) : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(item.key, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                      Text(
                        '₹${item.value.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(colors[index % colors.length]),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _TopProductsList extends StatelessWidget {
  final List<MapEntry<String, int>> products;

  const _TopProductsList({required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          
          return ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: index == 0 ? Colors.amber : (index == 1 ? Colors.grey[400] : Colors.brown[300]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            title: Text(product.key, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${product.value} sold',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TopBrandsList extends StatelessWidget {
  final List<MapEntry<String, double>> brands;

  const _TopBrandsList({required this.brands});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: brands.asMap().entries.map((entry) {
          final index = entry.key;
          final brand = entry.value;
          
          return ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: [
                Colors.blue[100],
                Colors.green[100],
                Colors.orange[100],
                Colors.purple[100],
                Colors.teal[100],
              ][index % 5],
              child: Text(
                brand.key.isNotEmpty ? brand.key[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
              ),
            ),
            title: Text(brand.key, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Text(
              '₹${brand.value.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Category-wise breakdown with Top 3 Brands per category
class _CategoryBrandBreakdown extends StatelessWidget {
  final Map<String, int> salesByCategory;
  final Map<String, Map<String, int>> brandsByCategory;
  final Map<String, Map<String, double>> revenueBrandsByCategory;
  final Map<String, double> revenueByCategory;

  const _CategoryBrandBreakdown({
    required this.salesByCategory,
    required this.brandsByCategory,
    required this.revenueBrandsByCategory,
    required this.revenueByCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Sort categories by revenue
    final sortedCategories = revenueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoryIcons = {
      'Rice & Grains': Icons.rice_bowl,
      'Cooking Oil': Icons.water_drop,
      'Flour & Atta': Icons.bakery_dining,
      'Spices & Masala': Icons.local_fire_department,
      'Masala & Spices': Icons.local_fire_department,
      'Dairy': Icons.local_drink,
      'Dairy Products': Icons.local_drink,
      'Noodles & Pasta': Icons.ramen_dining,
      'Noodles': Icons.ramen_dining,
      'Biscuits': Icons.cookie,
      'Biscuits & Snacks': Icons.cookie,
      'Snacks': Icons.fastfood,
      'Beverages': Icons.coffee,
      'Cold Drinks': Icons.local_cafe,
      'Cleaning & Household': Icons.cleaning_services,
      'Household': Icons.cleaning_services,
      'Personal Care': Icons.face,
      'Chocolates': Icons.cake,
      'Chocolate Bars': Icons.icecream,
      'Premium Chocolates': Icons.star,
      'Spreads': Icons.breakfast_dining,
      'Jams & Honey': Icons.egg_alt,
      'Toppings & Syrups': Icons.water_drop,
      'Vegetables': Icons.eco,
      'Fruits': Icons.apple,
      'Eggs': Icons.egg,
      'Bakery': Icons.bakery_dining,
      'Shampoo': Icons.wash,
      'Conditioner': Icons.water_drop,
      'Hair Oils': Icons.opacity,
      'Hair Serum': Icons.auto_awesome,
    };

    final categoryColors = [
      Colors.orange,
      Colors.amber,
      Colors.brown,
      Colors.red,
      Colors.blue,
      Colors.yellow[700]!,
      Colors.deepOrange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.purple,
    ];

    return Column(
      children: sortedCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value.key;
        final categoryRevenue = entry.value.value;
        final categorySales = salesByCategory[category] ?? 0;
        final brands = brandsByCategory[category] ?? {};
        final brandRevenue = revenueBrandsByCategory[category] ?? {};

        // Get top 3 brands for this category
        final sortedBrands = brands.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top3Brands = sortedBrands.take(3).toList();

        final color = categoryColors[index % categoryColors.length];
        final icon = categoryIcons[category] ?? Icons.category;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              title: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${categoryRevenue.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$categorySales sold',
                      style: TextStyle(color: Colors.blue[700], fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              children: [
                if (top3Brands.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No brand data', style: TextStyle(color: AppColors.textLight)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                            SizedBox(width: 6),
                            Text(
                              'Top 3 Brands',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...top3Brands.asMap().entries.map((brandEntry) {
                          final rankIndex = brandEntry.key;
                          final brand = brandEntry.value;
                          final brandRev = brandRevenue[brand.key] ?? 0.0;
                          
                          final medals = [
                            {'color': Colors.amber, 'icon': Icons.looks_one},
                            {'color': Colors.grey, 'icon': Icons.looks_two},
                            {'color': Colors.brown[300]!, 'icon': Icons.looks_3},
                          ];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (medals[rankIndex]['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: (medals[rankIndex]['color'] as Color).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  medals[rankIndex]['icon'] as IconData,
                                  color: medals[rankIndex]['color'] as Color,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        brand.key,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${brand.value} units sold',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${brandRev.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    const Text(
                                      'revenue',
                                      style: TextStyle(fontSize: 10, color: AppColors.textLight),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final List<SaleTransaction> transactions;

  const _TransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: transactions.map((tx) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tx.paymentMethod == 'Cash' 
                    ? Colors.green[50] 
                    : (tx.paymentMethod == 'UPI' ? Colors.purple[50] : Colors.blue[50]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                tx.paymentMethod == 'Cash' 
                    ? Icons.money 
                    : (tx.paymentMethod == 'UPI' ? Icons.phone_android : Icons.credit_card),
                color: tx.paymentMethod == 'Cash' 
                    ? Colors.green 
                    : (tx.paymentMethod == 'UPI' ? Colors.purple : Colors.blue),
                size: 20,
              ),
            ),
            title: Text(
              '₹${tx.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${tx.items.length} items • ${tx.paymentMethod}',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            trailing: Text(
              _formatTime(tx.timestamp),
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No sales data yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          SizedBox(height: 8),
          Text(
            'Complete some sales to see your analytics here.\nTap "Demo Data" to see sample data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
