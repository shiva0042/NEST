import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:near_basket/core/constants/app_colors.dart';
import 'package:near_basket/core/providers/sales_provider.dart';
import 'package:near_basket/core/providers/auth_provider.dart';
import 'package:near_basket/features/map_discovery/models/product_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedPeriod = 0; // 0: This Month, 1: Last 3 Months, 2: This Year

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesProvider>();
    final auth = context.watch<AuthProvider>();
    
    final userPhone = auth.userPhone ?? 'demo';
    
    // Fetch all analytics data
    final spending = sales.getCustomerCategorySpending(userPhone);
    final projectedBill = sales.predictCustomerMonthlyBill(userPhone);
    final suggestions = sales.getSmartSuggestions(userPhone);
    
    final weeklyPattern = sales.getCustomerWeeklyPattern(userPhone);
    final hourlyPattern = sales.getCustomerHourlyPattern(userPhone);
    final topBrands = sales.getCustomerTopBrands(userPhone);
    final categoryGrowth = sales.getCustomerCategoryGrowth(userPhone);
    final paymentStats = sales.getCustomerPaymentStats(userPhone);
    final savingsTrend = sales.getCustomerSavingsTrend(userPhone);
    final purchaseFreq = sales.getCustomerPurchaseFrequency(userPhone);
    final forecast = sales.getCustomerSpendingForecast(userPhone);
    
    double currentTotal = spending.values.fold(0, (val, item) => val + item);
    double budget = projectedBill * 1.2; // 20% buffer
    double savings = budget - currentTotal;
    // Calculate actual savings mock
    double totalSavings = savingsTrend.fold(0, (v, e) => v + (e['saving'] as double));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Smart Wallet'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                final userPhone = context.read<AuthProvider>().userPhone;
                sales.addDemoData('1', userPhone);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                     content: Text('Demo data loaded successfully!'),
                     backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.science, size: 18),
              label: const Text('Load Demo Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 20),

            // --- SECTION 1: OVERVIEW ---
            _buildSectionHeader('Overview', Icons.dashboard),
            _buildProjectorCard(currentTotal, projectedBill),
            const SizedBox(height: 20),
            _buildQuickStats(currentTotal, projectedBill, totalSavings, spending.length),
            const SizedBox(height: 20),
            const Text('Cumulative Savings Trend', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildSavingsTrendChart(savingsTrend),
            const SizedBox(height: 32),

            // --- SECTION 2: SPENDING ANALYSIS ---
            _buildSectionHeader('Spending Analysis', Icons.pie_chart),
            
            const Text('Spending Breakdown', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildSpendingPieChart(spending),
            const SizedBox(height: 24),
            
            const Text('Weekly Spending Habits', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildWeeklyChart(weeklyPattern),
            const SizedBox(height: 24),

            const Text('Category Growth (This vs Last Month)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildCategoryGrowthChart(categoryGrowth),
            const SizedBox(height: 24),

            const Text('Category Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildCategoryList(spending, currentTotal),
             const SizedBox(height: 32),

            // --- SECTION 3: INSIGHTS & HABITS ---
            _buildSectionHeader('Insights & Habits', Icons.lightbulb),
            
            const Text('Monthly Spending Trend', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildTrendChart(),
            const SizedBox(height: 24),

            const Text('Hourly Activity (Peak Shopping Times)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildHourlyChart(hourlyPattern),
            const SizedBox(height: 24),

            const Text('Purchase Frequency Heatmap (Day vs Hour)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildPurchaseHeatmap(purchaseFreq),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildPaymentDistributionChart(paymentStats),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text('Top Brands', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                       const SizedBox(height: 8),
                       _buildTopBrandsChart(topBrands),
                     ],
                  ),
                ),
              ],
            ),
             const SizedBox(height: 32),

            // --- SECTION 4: PLANNING ---
            _buildSectionHeader('Smart Planning', Icons.trending_up),
            
            const Text('Spending Forest (Next 3 Months)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildForecastChart(forecast),
            const SizedBox(height: 24),

            const Text('Budget Tracker', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildSavingsTracker(budget, currentTotal, savings),
            const SizedBox(height: 24),
            
            const Text('Smart Suggestions for You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 12),
              child: Text('Based on your shopping patterns', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            _buildSuggestionsList(suggestions),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 60,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Expanded(child: _periodButton('This Month', 0)),
          Expanded(child: _periodButton('Last 3 Months', 1)),
          Expanded(child: _periodButton('This Year', 2)),
        ],
      ),
    );
  }
  
  Widget _periodButton(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildProjectorCard(double current, double projected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_graph, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Monthly Projector',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spent so far', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${current.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(height: 50, width: 1, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Projected Total', style: TextStyle(color: Colors.orangeAccent, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${projected.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_down, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are saving ₹${(projected * 0.15).toStringAsFixed(0)} compared to last month!',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStats(double spent, double projected, double savings, int categories) {
    return Row(
      children: [
        Expanded(child: _statCard('Categories', categories.toString(), Icons.category, Colors.purple)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Avg/Day', '₹${(spent / DateTime.now().day).toStringAsFixed(0)}', Icons.calendar_today, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Savings', '₹${savings.toStringAsFixed(0)}', Icons.savings, Colors.green)),
      ],
    );
  }
  
  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpendingPieChart(Map<String, double> data) {
    if (data.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Start shopping to see your spending breakdown!', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    final colors = [
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFFF9FF3),
      const Color(0xFFFECA57),
    ];
    
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final total = data.values.fold(0.0, (sum, val) => sum + val);
                  final percentage = (item.value / total * 100);
                  
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: item.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedEntries.take(5).map((entry) {
                final index = sortedEntries.indexOf(entry);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrendChart() {
    // Mock data for monthly trend
    final spots = [
      const FlSpot(1, 1200),
      const FlSpot(2, 1500),
      const FlSpot(3, 1300),
      const FlSpot(4, 1800),
      const FlSpot(5, 1600),
      const FlSpot(6, 2000),
      const FlSpot(7, 1900),
    ];
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                  return Text(
                    months[value.toInt()],
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: 2500,
        ),
      ),
    );
  }
  
  Widget _buildCategoryList(Map<String, double> spending, double total) {
    if (spending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No spending data yet', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    
    final sortedEntries = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEntries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final percentage = (entry.value / total * 100);
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                entry.key.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSavingsTracker(double budget, double spent, double savings) {
    final percentage = (spent / budget * 100).clamp(0, 100);
    final isOverBudget = spent > budget;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  const Text('Monthly Budget', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('₹${budget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverBudget ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverBudget ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _budgetStat('Spent', spent, Colors.orange),
              _budgetStat('Remaining', savings > 0 ? savings : 0, Colors.green),
              if (isOverBudget) _budgetStat('Over Budget', savings.abs(), Colors.red),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _budgetStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
  
  Widget _buildSuggestionsList(List<ProductModel> products) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No suggestions yet. Start shopping to get personalized recommendations!', 
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                p.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Because you like ${p.category}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('₹${p.price.toStringAsFixed(0)}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${p.name} added to wishlist!')),
                );
              },
            ),
          ),
        );
      },
    );
  }
  // --- NEW CHARTS START ---

  Widget _buildPaymentDistributionChart(Map<String, int> data) {
    if (data.isEmpty) return _buildEmptyState('No payment data');

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: data.entries.map((e) {
                   final total = data.values.fold(0, (a,b) => a+b);
                   final percentage = e.value / total * 100;
                   Color color;
                   if(e.key == 'Cash') {
                     color = Colors.green;
                   } else if(e.key == 'UPI') {
                     color = Colors.orange;
                   } else {
                     color = Colors.purple;
                   }
                   
                   return PieChartSectionData(
                     value: e.value.toDouble(),
                     color: color,
                     title: '${percentage.toStringAsFixed(0)}%',
                     radius: 40,
                     titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                   );
                }).toList(),
              )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((e) {
               Color color;
               if(e.key == 'Cash') {
                 color = Colors.green;
               } else if(e.key == 'UPI') {
                 color = Colors.orange;
               } else {
                 color = Colors.purple;
               }
               
               return Padding(
                 padding: const EdgeInsets.only(bottom: 8.0),
                 child: Row(
                   children: [
                     Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                     const SizedBox(width: 8),
                     Text('${e.key}: ${e.value}'),
                   ],
                 ),
               );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryGrowthChart(Map<String, Map<String, double>> data) {
    // Top 3 categories only to avoid clutter
    final thisMonth = data['thisMonth'] ?? {};
    final lastMonth = data['lastMonth'] ?? {};
    
    // Sort categories by this month spend
    final categories = thisMonth.keys.toList()
      ..sort((a,b) => (thisMonth[b] ?? 0).compareTo(thisMonth[a] ?? 0));
    final topCategories = categories.take(4).toList();
    
    if(topCategories.isEmpty) return _buildEmptyState('Not enough data for growth comparison');

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if(value.toInt() >= 0 && value.toInt() < topCategories.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: 60,
                        child: Text(topCategories[value.toInt()], 
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]), 
                          overflow: TextOverflow.ellipsis),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: topCategories.asMap().entries.map((e) {
            final cat = e.value;
            final v1 = lastMonth[cat] ?? 0;
            final v2 = thisMonth[cat] ?? 0;
            
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(toY: v1, color: Colors.grey[300], width: 12),
                BarChartRodData(toY: v2, color: AppColors.primary, width: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildForecastChart(List<double> forecast) {
    if(forecast.isEmpty) return _buildEmptyState('Not enough data to forecast');
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final now = DateTime.now();
                  final month = DateTime(now.year, now.month + 1 + value.toInt()).month;
                  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(months[month], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
           borderData: FlBorderData(show: false),
           gridData: const FlGridData(show: false),
           barGroups: forecast.asMap().entries.map((e) {
             return BarChartGroupData(
               x: e.key,
               barRods: [
                 BarChartRodData(
                   toY: e.value, 
                   color: Colors.purpleAccent,
                   width: 24,
                   borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                 )
               ]
             );
           }).toList(),
        ),
      ),
    );
  }

  Widget _buildPurchaseHeatmap(List<Map<String, dynamic>> data) {
    if(data.isEmpty) return _buildEmptyState('No purchase patterns yet');

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: data.map((e) {
             return ScatterSpot(
               e['day'].toDouble(), 
               e['hour'].toDouble(),
               dotPainter: FlDotCirclePainter(
                 radius: (e['count'] as int).toDouble() * 2 + 2,
                 color: AppColors.primary.withOpacity(0.6),
                 strokeColor: Colors.transparent,
               ),
             );
          }).toList(),
          minX: 0, maxX: 6,
          minY: 0, maxY: 23,
          gridData: FlGridData(
             show: true,
             drawHorizontalLine: true,
             horizontalInterval: 6,
             drawVerticalLine: true,
             verticalInterval: 1,
             getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade100),
             getDrawingVerticalLine: (val) => FlLine(color: Colors.grey.shade100),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade200)),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                   const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                   if(val.toInt() >= 0 && val.toInt() < days.length) {
                     return Text(days[val.toInt()], style: const TextStyle(fontSize: 10));
                   }
                   return const SizedBox();
                }
              )
            ),
               leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                getTitlesWidget: (val, meta) => Text('${val.toInt()}h', style: const TextStyle(fontSize: 10))
              )
            ),
             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // touchData removed as it was undefined
        ),
      ),
    );
  }

  Widget _buildSavingsTrendChart(List<Map<String, dynamic>> data) {
     if(data.isEmpty) return _buildEmptyState('Savings data loading...');
     
     List<FlSpot> spots = [];
     for(var d in data) {
       spots.add(FlSpot((d['month'] as int).toDouble(), d['saving'] as double));
     }
     
     return Container(
       height: 180,
       padding: const EdgeInsets.all(16),
       decoration: _cardDecoration(),
       child: LineChart(
         LineChartData(
           gridData: const FlGridData(show: false),
           titlesData: FlTitlesData(
             show: true,
             bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (val, _) {
                 const months = ['', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                 if(val.toInt() >= 1 && val.toInt() <= 12) return Text(months[val.toInt()], style: const TextStyle(fontSize: 10));
                 return const SizedBox();
             })),
             leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           ),
           borderData: FlBorderData(show: false),
           lineBarsData: [
             LineChartBarData(
               spots: spots,
               isCurved: true,
               color: Colors.green,
               barWidth: 3,
               belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
               dotData: const FlDotData(show: true),
             )
           ]
         )
       ),
     );
  }
  
  Widget _buildWeeklyChart(List<double> data) {
    if (data.isEmpty || data.every((e) => e == 0)) return _buildEmptyState('No weekly data yet');
    
    // Calculate max value safely without reduce generics issues
    double maxY = 0;
    for(var val in data) {
      if(val > maxY) maxY = val;
    }
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 return BarTooltipItem(
                   '₹${rod.toY.toStringAsFixed(0)}',
                   const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                 );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(days[value.toInt()], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                     );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: e.value > 0 ? AppColors.primary : Colors.grey[200],
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.1,
                    color: Colors.grey[100],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHourlyChart(List<double> data) {
    if (data.every((e) => e == 0)) return _buildEmptyState('No hourly activity yet');
    
    List<FlSpot> spots = [];
    for(int i=0; i<data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('${value.toInt()}h', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
          ],
          minX: 0,
          maxX: 23,
          minY: 0,
        ),
      ),
    );
  }

  Widget _buildTopBrandsChart(Map<String, double> data) {
    if (data.isEmpty) return _buildEmptyState('No brands data yet');
    
    final sorted = data.entries.toList();
    final maxVal = sorted.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: sorted.map((e) {
          final percentage = e.value / maxVal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(e.key, overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                ),
                Expanded(
                  child: Stack(
                    children: [
                       Container(
                         height: 12,
                         decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                       ),
                       FractionallySizedBox(
                         widthFactor: percentage,
                         child: Container(
                           height: 12,
                           decoration: BoxDecoration(
                             gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)]),
                             borderRadius: BorderRadius.circular(6),
                           ),
                         ),
                       )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('₹${e.value.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(String msg) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: _cardDecoration(),
      alignment: Alignment.center,
      child: Text(msg, style: TextStyle(color: Colors.grey[400])),
    );
  }
}
