import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/sales_provider.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Month'; // Today, Week, Month, Year
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final shopId = context.watch<StoreProvider>().currentShopId;
    final salesProvider = context.watch<SalesProvider>();
    
    // Get analytics based on selection
    AnalyticsSummary analytics;
    switch (_selectedPeriod) {
      case 'Today':
        analytics = salesProvider.getTodayAnalytics(shopId);
        break;
      case 'Week':
        analytics = salesProvider.getWeekAnalytics(shopId);
        break;
      case 'Year':
        analytics = salesProvider.getYearAnalytics(shopId);
        break;
      case 'Month':
      default:
        analytics = salesProvider.getMonthAnalytics(shopId);
    }

    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWeb ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSummaryCards(analytics, isWeb),
            const SizedBox(height: 24),
            if (isWeb)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRevenueChart(shopId, salesProvider)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildCategoryPieChart(analytics)),
                ],
              )
            else
              Column(
                children: [
                  _buildRevenueChart(shopId, salesProvider),
                  const SizedBox(height: 24),
                  _buildCategoryPieChart(analytics),
                ],
              ),
            const SizedBox(height: 24),
            _buildTopProductsTable(shopId, salesProvider),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Track your store performance and growth',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Today', 'Week', 'Month', 'Year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return InkWell(
            onTap: () => setState(() => _selectedPeriod = period),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(AnalyticsSummary analytics, bool isWeb) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isWeb 
            ? (constraints.maxWidth - 48) / 4 
            : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildKpiCard(
              'Total Revenue',
              '₹${analytics.totalRevenue.toStringAsFixed(0)}',
              Icons.currency_rupee,
              Colors.blue,
              cardWidth,
              '+12%', 
            ),
            _buildKpiCard(
              'Net Profit',
              '₹${analytics.totalProfit.toStringAsFixed(0)}',
              Icons.trending_up,
              Colors.green,
              cardWidth,
              '+8%',
            ),
            _buildKpiCard(
              'Transactions',
              analytics.totalTransactions.toString(),
              Icons.receipt_long,
              Colors.orange,
              cardWidth,
              '-2%',
            ),
            _buildKpiCard(
              'Avg Order Value',
              '₹${analytics.totalTransactions > 0 ? (analytics.totalRevenue / analytics.totalTransactions).toStringAsFixed(0) : "0"}',
              Icons.shopping_basket,
              Colors.purple,
              cardWidth,
              '+5%',
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, double width, String trend) {
    final isPositive = trend.startsWith('+');
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(String shopId, SalesProvider salesProvider) {
    // Get distinct date ranges based on selection
    DateTime endDate = DateTime.now();
    DateTime startDate;
    switch(_selectedPeriod) {
      case 'Today':
        startDate = endDate.subtract(const Duration(hours: 24)); // Actually needs hourly, but reusing daily for now
        break;
      case 'Week':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      case 'Year':
        startDate = endDate.subtract(const Duration(days: 365));
        break;
      default:
        startDate = endDate.subtract(const Duration(days: 30));
    }

    final data = salesProvider.getDailyRevenueData(shopId, startDate: startDate, endDate: endDate);

    // Prepare spots for chart
    List<FlSpot> spots = [];
    double maxRevenue = 0;
    
    for (int i = 0; i < data.length; i++) {
        double revenue = (data[i]['revenue'] as double);
        if (revenue > maxRevenue) maxRevenue = revenue;
        spots.add(FlSpot(i.toDouble(), revenue));
    }
    
    // Add dummy data if empty to prevent crash
    if (spots.isEmpty) {
        spots = [const FlSpot(0, 0), const FlSpot(1, 100), const FlSpot(2, 50)];
        maxRevenue = 100;
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Sales performance over time', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxRevenue > 0 ? maxRevenue / 5 : 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: data.length > 5 ? (data.length / 5).toDouble() : 1,
                      getTitlesWidget: (value, meta) {
                         int idx = value.toInt();
                         if (idx >= 0 && idx < data.length) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(
                                 data[idx]['day'],
                                 style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
                               ),
                             );
                         }
                         return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxRevenue > 0 ? maxRevenue / 5 : 10,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatCurrencyCompact(value),
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxRevenue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF6E40C9)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                 lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.black87,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '₹${flSpot.y.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrencyCompact(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildCategoryPieChart(AnalyticsSummary analytics) {
    // Top 4 categories
    final sorted = analytics.revenueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top4 = sorted.take(4).toList();
    final othersValue = sorted.skip(4).fold(0.0, (val, entry) => val + entry.value);
    
    if (othersValue > 0) {
      top4.add(MapEntry('Others', othersValue));
    }

    if (top4.isEmpty) {
       return Container(
         height: 400,
         padding: const EdgeInsets.all(24),
         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
         child: const Center(child: Text('No data available')),
       );
    }

    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.grey,
    ];

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Distribution of revenue', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: List.generate(top4.length, (i) {
                        final isTouched = i == _touchedIndex;
                        final fontSize = isTouched ? 16.0 : 12.0;
                        final radius = isTouched ? 60.0 : 50.0;
                        final entry = top4[i];
                        final percent = (entry.value / analytics.totalRevenue * 100);
                        
                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: entry.value,
                          title: '${percent.toStringAsFixed(0)}%',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ), 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(top4.length, (i) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Row(
                         children: [
                           Container(
                             width: 12,
                             height: 12,
                             decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle),
                           ),
                           const SizedBox(width: 8),
                           Text(top4[i].key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                         ],
                       ),
                     );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsTable(String shopId, SalesProvider salesProvider) {
    final products = salesProvider.getTopProducts(shopId, limit: 5);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Selling Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('PRODUCT', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('CATEGORY', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('PRICE', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('SOLD', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ...products.map((item) {
                final product = item['product'] as ProductModel;
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                              image: NetworkImage(product.imageUrl).toString().isNotEmpty 
                                  ? DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover) 
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(product.unit, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(product.category, style: const TextStyle(fontSize: 14)),
                    Text('₹${product.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item['quantity']} sold',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
