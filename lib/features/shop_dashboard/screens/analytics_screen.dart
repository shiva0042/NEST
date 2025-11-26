import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Week'; // Day, Week, Month

  @override
  Widget build(BuildContext context) {
    final shopId = context.read<StoreProvider>().currentShopId;
    final products = mockProducts.where((p) => p.shopId == shopId).toList();
    
    // Generate mock sales data based on selected period
    final Map<String, double> categorySales = {};
    final Map<String, double> brandSales = {};
    double totalSales = 0;
    int totalOrders = 0;

    final random = Random(shopId.hashCode); // Consistent random for same shop
    
    int multiplier = _selectedPeriod == 'Day' ? 1 : (_selectedPeriod == 'Week' ? 7 : 30);

    for (var p in products) {
      // Simulate sales: random quantity * price * period multiplier
      int quantitySold = random.nextInt(5) * multiplier; 
      double revenue = quantitySold * p.price;

      if (quantitySold > 0) {
        totalSales += revenue;
        totalOrders += random.nextInt(3) * multiplier; // Rough estimate of orders

        // Aggregate by Category
        categorySales[p.category] = (categorySales[p.category] ?? 0) + revenue;

        // Aggregate by Brand
        brandSales[p.brand] = (brandSales[p.brand] ?? 0) + revenue;
      }
    }

    // Sort Maps
    final sortedCategories = categorySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final sortedBrands = brandSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Analytics', style: TextStyle(color: AppColors.text)),
        iconTheme: IconThemeData(color: AppColors.text),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              underline: SizedBox(),
              icon: Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                });
              },
              items: <String>['Day', 'Week', 'Month']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview ($_selectedPeriod)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AnalyticsCard(
                    title: 'Total Sales',
                    value: '₹${totalSales.toStringAsFixed(0)}',
                    color: AppColors.primary,
                    icon: Icons.attach_money,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _AnalyticsCard(
                    title: 'Orders',
                    value: '$totalOrders',
                    color: AppColors.secondary,
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            
            // Category Analysis
            Text(
              'Sales by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: sortedCategories.take(5).map((entry) {
                  double percentage = (entry.value / totalSales);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('₹${entry.value.toStringAsFixed(0)}'),
                          ],
                        ),
                        SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.background,
                          color: AppColors.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 32),

            // Brand Analysis
            Text(
              'Top Selling Brands',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: sortedBrands.take(5).map((entry) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      child: Text(
                        entry.key[0],
                        style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      '₹${entry.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
