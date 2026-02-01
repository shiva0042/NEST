import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/map_discovery/models/product_model.dart';
import 'dart:math' as math;

// Sale Item - Individual item in a sale
class SaleItem {
  final ProductModel product;
  final int quantity;
  final double unitPrice;
  final double costPrice; // For profit calculation
  
  SaleItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.costPrice = 0,
  });
  
  double get totalPrice => unitPrice * quantity;
  double get profit => (unitPrice - costPrice) * quantity;
}

// Sale Transaction - Complete bill/sale
class SaleTransaction {
  static const String collectionName = 'sales';
  
  final String id;
  final String shopId;
  final DateTime timestamp;
  final List<SaleItem> items;
  final String? customerPhone;
  final String paymentMethod;
  
  SaleTransaction({
    required this.id,
    required this.shopId,
    required this.timestamp,
    required this.items,
    this.customerPhone,
    this.paymentMethod = 'Cash',
  });
  
  double get totalAmount => items.fold(0, (val, item) => val + item.totalPrice);
  double get totalProfit => items.fold(0, (val, item) => val + item.profit);
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'timestamp': Timestamp.fromDate(timestamp),
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name, // denormalize for analytics
        'categoryId': item.product.category, // denormalize
        'brand': item.product.brand, // denormalize
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'costPrice': item.costPrice,
      }).toList(),
      'totalAmount': totalAmount,
    };
  }
}



// Low Stock Alert Model
class LowStockAlert {
  final ProductModel product;
  final int currentStock;
  
  LowStockAlert({
    required this.product,
    required this.currentStock,
  });

  bool get isCritical => currentStock < 5;
}

// Analytics Summary Model
class AnalyticsSummary {
  final double totalRevenue;
  final double totalProfit;
  final int totalTransactions;
  final int totalItemsSold;
  final Map<String, double> revenueByCategory;
  final Map<String, int> salesByProduct;
  final Map<String, double> revenueByBrand;
  final Map<String, int> salesByCategory;
  final Map<String, Map<String, int>> brandsByCategory;
  final Map<String, Map<String, double>> revenueBrandsByCategory;
  final List<SaleTransaction> transactions;

  AnalyticsSummary({
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalTransactions,
    required this.totalItemsSold,
    required this.revenueByCategory,
    required this.salesByProduct,
    required this.revenueByBrand,
    required this.salesByCategory,
    required this.brandsByCategory,
    required this.revenueBrandsByCategory,
    required this.transactions,
  });
}

class SalesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<SaleTransaction> _transactions = [];
  final List<LowStockAlert> _lowStockAlerts = [];
  static const int lowStockThreshold = 10;
  
  List<SaleTransaction> get transactions => List.unmodifiable(_transactions);
  List<LowStockAlert> get lowStockAlerts => List.unmodifiable(_lowStockAlerts);
  
  // Record a new sale with Transaction
  Future<void> recordSale({
    required String shopId,
    required Map<ProductModel, int> cartItems,
    String? customerPhone,
    String paymentMethod = 'Cash',
  }) async {
    final saleItems = cartItems.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      final costPrice = product.price * 0.8;
      
      return SaleItem(
        product: product,
        quantity: quantity,
        unitPrice: product.price,
        costPrice: costPrice,
      );
    }).toList();
    
    final newId = _firestore.collection(SaleTransaction.collectionName).doc().id;

    final transaction = SaleTransaction(
      id: newId,
      shopId: shopId,
      timestamp: DateTime.now(),
      items: saleItems,
      customerPhone: customerPhone,
      paymentMethod: paymentMethod,
    );

    // Firestore Logic
    final newSaleRef = _firestore.collection(SaleTransaction.collectionName).doc(newId);
    
    // Batch write for atomicity
    final batch = _firestore.batch();
    
    // 1. Create Sale Document
    batch.set(newSaleRef, transaction.toMap());
    
    // 2. Decrement Stock for each product
    for (var entry in cartItems.entries) {
      final product = entry.key;
      final quantity = entry.value;
      
      // Assume ProductModel has a collectionName, or hardcode 'products'
      final productRef = _firestore.collection('products').doc(product.id);
      batch.update(productRef, {
        'stockQuantity': FieldValue.increment(-quantity),
        'inStock': quantity >= product.stockQuantity ? false : true, // This logic is approximate
      });
    }

    try {
      await batch.commit();
      _transactions.add(transaction); // Optimistic update
      notifyListeners();
      debugPrint('Sale recorded successfully: ${transaction.id}');
    } catch (e) {
      debugPrint('Error recording sale: $e');
    }
  }
  
  void _updateInventoryAndCheckAlerts(Map<ProductModel, int> cartItems, String shopId) {
    for (var entry in cartItems.entries) {
      final product = entry.key;
      final soldQuantity = entry.value;
      
      // Find and update in mockProducts
      final index = mockProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final currentStock = mockProducts[index].stockQuantity;
        final newStock = currentStock - soldQuantity;
        
        // Update product
        mockProducts[index] = ProductModel(
          id: product.id,
          shopId: product.shopId,
          name: product.name,
          price: product.price,
          originalPrice: product.originalPrice,
          imageUrl: product.imageUrl,
          inStock: newStock > 0,
          stockQuantity: newStock > 0 ? newStock : 0,
          category: product.category,
          brand: product.brand,
          unit: product.unit,
        );
        
        // Check for low stock alert
        if (newStock <= lowStockThreshold && newStock > 0) {
          _addLowStockAlert(mockProducts[index], newStock);
        }
      }
    }
  }
  
  void _addLowStockAlert(ProductModel product, int currentStock) {
    // Check if alert already exists
    final existingIndex = _lowStockAlerts.indexWhere((a) => a.product.id == product.id);
    if (existingIndex != -1) {
      _lowStockAlerts[existingIndex] = LowStockAlert(
        product: product,
        currentStock: currentStock,
      );
    } else {
      _lowStockAlerts.add(LowStockAlert(
        product: product,
        currentStock: currentStock,
      ));
    }
  }
  
  void dismissAlert(String productId) {
    _lowStockAlerts.removeWhere((a) => a.product.id == productId);
    notifyListeners();
  }
  
  void clearAllAlerts() {
    _lowStockAlerts.clear();
    notifyListeners();
  }
  
  // Get analytics for a specific time period
  AnalyticsSummary getAnalytics({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filteredTransactions = _transactions.where((t) =>
      t.shopId == shopId &&
      t.timestamp.isAfter(startDate) &&
      t.timestamp.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
    
    double totalRevenue = 0;
    double totalProfit = 0;
    int totalItemsSold = 0;
    Map<String, double> revenueByCategory = {};
    Map<String, int> salesByProduct = {};
    Map<String, double> revenueByBrand = {};
    Map<String, int> salesByCategory = {};
    Map<String, Map<String, int>> brandsByCategory = {};
    Map<String, Map<String, double>> revenueBrandsByCategory = {};
    
    for (var transaction in filteredTransactions) {
      for (var item in transaction.items) {
        totalRevenue += item.totalPrice;
        totalProfit += item.profit;
        totalItemsSold += item.quantity;
        
        final category = item.product.category;
        final brand = item.product.brand;
        final productName = item.product.name;
        
        // By Category - Revenue
        revenueByCategory[category] = (revenueByCategory[category] ?? 0) + item.totalPrice;
        
        // By Category - Units Sold
        salesByCategory[category] = (salesByCategory[category] ?? 0) + item.quantity;
        
        // By Product
        salesByProduct[productName] = (salesByProduct[productName] ?? 0) + item.quantity;
        
        // By Brand - Overall
        revenueByBrand[brand] = (revenueByBrand[brand] ?? 0) + item.totalPrice;
        
        // Brands by Category - Units Sold
        if (!brandsByCategory.containsKey(category)) {
          brandsByCategory[category] = {};
        }
        brandsByCategory[category]![brand] = (brandsByCategory[category]![brand] ?? 0) + item.quantity;
        
        // Brands by Category - Revenue
        if (!revenueBrandsByCategory.containsKey(category)) {
          revenueBrandsByCategory[category] = {};
        }
        revenueBrandsByCategory[category]![brand] = (revenueBrandsByCategory[category]![brand] ?? 0) + item.totalPrice;
      }
    }
    
    return AnalyticsSummary(
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      totalTransactions: filteredTransactions.length,
      totalItemsSold: totalItemsSold,
      revenueByCategory: revenueByCategory,
      salesByProduct: salesByProduct,
      revenueByBrand: revenueByBrand,
      salesByCategory: salesByCategory,
      brandsByCategory: brandsByCategory,
      revenueBrandsByCategory: revenueBrandsByCategory,
      transactions: filteredTransactions,
    );
  }
  
  // Convenience methods for time periods
  AnalyticsSummary getTodayAnalytics(String shopId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getAnalytics(shopId: shopId, startDate: startOfDay, endDate: now);
  }
  
  AnalyticsSummary getWeekAnalytics(String shopId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getAnalytics(shopId: shopId, startDate: start, endDate: now);
  }
  
  AnalyticsSummary getMonthAnalytics(String shopId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getAnalytics(shopId: shopId, startDate: startOfMonth, endDate: now);
  }
  
  AnalyticsSummary getYearAnalytics(String shopId) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return getAnalytics(shopId: shopId, startDate: startOfYear, endDate: now);
  }
  
  // Get daily revenue data for charts (dynamic range)
  List<Map<String, dynamic>> getDailyRevenueData(String shopId, {DateTime? startDate, DateTime? endDate}) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 6));
    
    List<Map<String, dynamic>> data = [];
    int days = end.difference(start).inDays + 1;
    if (days <= 0) days = 1;
    
    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayTransactions = _transactions.where((t) =>
        t.shopId == shopId &&
        t.timestamp.isAfter(dayStart) &&
        t.timestamp.isBefore(dayEnd)
      );
      
      final revenue = dayTransactions.fold(0.0, (val, t) => val + t.totalAmount);
      
      data.add({
        'day': _getDayName(date.weekday),
        'fullDate': '${date.day}/${date.month}',
        'date': date,
        'revenue': revenue,
      });
    }
    
    return data;
  }

  // --- NEW METHODS FOR ADVANCED ANALYTICS & ML ---

  // 1. Hourly Traffic Analysis (Last 24 hours or Average)
  List<Map<String, dynamic>> getHourlyTraffic(String shopId) {
    // 0-23 hours bucket
    Map<int, int> hourlyCounts = {};
    for (int i = 0; i < 24; i++) {
      hourlyCounts[i] = 0;
    }

    final todayTransactions = getTodayAnalytics(shopId).transactions;
    for (var t in todayTransactions) {
      hourlyCounts[t.timestamp.hour] = (hourlyCounts[t.timestamp.hour] ?? 0) + 1;
    }

    return List.generate(24, (index) {
      return {'hour': index, 'count': hourlyCounts[index] ?? 0};
    });
  }

  // 2. Sales Forecast (Linear Regression on last 7 days to predict next day)
  // Input: List of {date, revenue}
  // Output: Predicted revenue for tomorrow
  double getSalesForecast(String shopId) {
    final dailyData = getDailyRevenueData(shopId); // Last 7 days
    if (dailyData.isEmpty) return 0.0;

    // Simple Linear Regression: y = mx + c
    // x = day index (0 to 6), y = revenue
    int n = dailyData.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;

    for (int i = 0; i < n; i++) {
        double x = i.toDouble();
        double y = (dailyData[i]['revenue'] as double);
        sumX += x;
        sumY += y;
        sumXY += x * y;
        sumXX += x * x;
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    // Predict for next day (index = 7)
    double prediction = slope * 7 + intercept;
    return prediction > 0 ? prediction : 0;
  }

  // 3. Payment Method Distribution
  Map<String, int> getPaymentDistribution(String shopId) {
    final transactions = getMonthAnalytics(shopId).transactions;
    Map<String, int> distribution = {'Cash': 0, 'UPI': 0, 'Card': 0};
    
    for (var t in transactions) {
      distribution[t.paymentMethod] = (distribution[t.paymentMethod] ?? 0) + 1;
    }
    return distribution;
  }

  // 4. Profit Margin Analysis Trend (Last 7 days profit %)
  List<Map<String, dynamic>> getProfitTrend(String shopId) {
    final now = DateTime.now();
    List<Map<String, dynamic>> data = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayTransactions = _transactions.where((t) =>
        t.shopId == shopId &&
        t.timestamp.isAfter(dayStart) &&
        t.timestamp.isBefore(dayEnd)
      );

      double revenue = 0;
      double profit = 0;
      for(var t in dayTransactions) {
        revenue += t.totalAmount;
        profit += t.totalProfit;
      }
      
      double margin = revenue > 0 ? (profit / revenue) * 100 : 0;

      data.add({
        'day': _getDayName(date.weekday),
        'margin': margin,
      });
    }
    return data;
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
  
  // Get top selling products with full product info - Aggregated by ID first to avoid duplicates
  List<Map<String, dynamic>> getTopProducts(String shopId, {int limit = 5}) {
    final analytics = getMonthAnalytics(shopId);
    
    // Group by Product ID to ensure uniqueness
    Map<String, int> qtyById = {};
    Map<String, ProductModel> productById = {};
    
    for(var t in analytics.transactions) {
      for(var item in t.items) {
        qtyById[item.product.id] = (qtyById[item.product.id] ?? 0) + item.quantity;
        productById[item.product.id] = item.product;
      }
    }
    
    final sorted = qtyById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return sorted.take(limit).map((entry) {
      return {
        'product': productById[entry.key],
        'quantity': entry.value,
      };
    }).toList();
  }
  
  // Get top brands with product images
  List<Map<String, dynamic>> getTopBrands(String shopId, {int limit = 5}) {
    final analytics = getMonthAnalytics(shopId);
    final sorted = analytics.revenueByBrand.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get representative product for each brand to show image
    return sorted.take(limit).map((entry) {
      final brandName = entry.key;
      final revenue = entry.value;
      
      // Find a product from this brand
      final product = mockProducts.firstWhere(
        (p) => p.brand == brandName && p.shopId == shopId,
        orElse: () => mockProducts.first,
      );
      
      return {
        'brand': brandName,
        'revenue': revenue,
        'product': product, // Passing product to get image
      };
    }).toList();
  }

  // Get best selling product for each category
  List<Map<String, dynamic>> getCategoryBestSellers(String shopId) {
    final analytics = getMonthAnalytics(shopId);
    Map<String, Map<String, int>> productSalesByCategory = {};
    Map<String, ProductModel> productRef = {};

    // Group sales by category -> product
    for(var t in analytics.transactions) {
      for(var item in t.items) {
        final cat = item.product.category;
        final pid = item.product.id;
        
        if(!productSalesByCategory.containsKey(cat)) {
          productSalesByCategory[cat] = {};
        }
        productSalesByCategory[cat]![pid] = (productSalesByCategory[cat]![pid] ?? 0) + item.quantity;
        productRef[pid] = item.product;
      }
    }

    // Find top for each category
    List<Map<String, dynamic>> bestSellers = [];
    productSalesByCategory.forEach((category, products) {
        if(products.isEmpty) return;
        final topEntry = products.entries.reduce((a, b) => a.value > b.value ? a : b);
        bestSellers.add({
          'category': category,
          'product': productRef[topEntry.key],
          'quantity': topEntry.value,
        });
    });
    
    return bestSellers;
  }
  
  // ML Prediction: Predict Stock Needs
  // Uses Weighted Moving Average to forecast future demand
  List<Map<String, dynamic>> predictStockNeeds(String shopId, {required int daysAhead}) {
    // 1. Calculate Daily Sales Velocity for each product over last 30 days
    final analytics = getMonthAnalytics(shopId);
    Map<String, List<int>> dailySalesHistory = {}; // productId -> [sales_day1, sales_day2...]
    Map<String, ProductModel> productRef = {};

    // Initialize history
    final now = DateTime.now();
    for(var t in analytics.transactions) {
       for(var item in t.items) {
         productRef[item.product.id] = item.product;
         if(!dailySalesHistory.containsKey(item.product.id)) {
           dailySalesHistory[item.product.id] = List.filled(30, 0);
         }
         
         final dayDiff = now.difference(t.timestamp).inDays;
         if(dayDiff < 30 && dayDiff >= 0) {
           dailySalesHistory[item.product.id]![dayDiff] += item.quantity;
         }
       }
    }

    List<Map<String, dynamic>> predictions = [];

    dailySalesHistory.forEach((pid, history) {
        // Weighted Average: Recent days have more weight
        double weightedSum = 0;
        double weightTotal = 0;
        
        for(int i=0; i<history.length; i++) {
           // Day 0 is today (highest weight 30), Day 29 is 30 days ago (weight 1)
           double weight = (30 - i).toDouble(); 
           weightedSum += history[i] * weight;
           weightTotal += weight;
        }
        
        double avgDailySales = weightTotal > 0 ? weightedSum / weightTotal : 0;
        
        // Predict total needed for N days
        double predictedSales = avgDailySales * daysAhead;
        
        // Add safety stock buffer (10%)
        predictedSales *= 1.1; 
        
        if(predictedSales > 0.5) { // Only include meaningful predictions
          predictions.add({
             'product': productRef[pid],
             'predictedSales': predictedSales,
             'avgDaily': avgDailySales,
             'currentStock': productRef[pid]?.stockQuantity ?? 0,
          });
        }
    });
    
    // Sort by highest predicted demand
    predictions.sort((a,b) => (b['predictedSales'] as double).compareTo(a['predictedSales'] as double));
    
    return predictions;
  }
  
  // --- CUSTOMER ANALYTICS (OPTION 1) ---
  
  // Get spending breakdown for a specific customer
  Map<String, double> getCustomerCategorySpending(String phone) {
    Map<String, double> spending = {};
    for (var t in _transactions) {
      if (t.customerPhone == phone || phone == 'demo') { // Allow 'demo' to show all data for testing
         for (var item in t.items) {
           spending[item.product.category] = (spending[item.product.category] ?? 0) + item.totalPrice;
         }
      }
    }
    return spending;
  }
  
  // Predict monthly bill based on current spending rate (Simple ML: Linear Projection)
  double predictCustomerMonthlyBill(String phone) {
     double currentSpending = 0;
     DateTime now = DateTime.now();
     DateTime startOfMonth = DateTime(now.year, now.month, 1);
     int daysPassed = now.day;
     
     for (var t in _transactions) {
       if ((t.customerPhone == phone || phone == 'demo') && t.timestamp.isAfter(startOfMonth)) {
         currentSpending += t.totalAmount;
       }
     }
     
     if (daysPassed == 0) return 0;
     
     // Projection: (Current / daysPassed) * daysInMonth
     int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
     return (currentSpending / daysPassed) * daysInMonth;
  }
  
  // Get Smart Suggestions (Market Basket Analysis - simplified)
  List<ProductModel> getSmartSuggestions(String phone) {
     // For demo: Suggest top products from categories the user buys often
     final spending = getCustomerCategorySpending(phone);
     if (spending.isEmpty) return mockProducts.take(3).toList();
     
     final topCategory = spending.entries.reduce((a, b) => a.value > b.value ? a : b).key;
     
     // Recommend items from this category that are "on sale" or popular
     return mockProducts.where((p) => p.category == topCategory).take(3).toList();
  }

  // --- NEW CUSTOMER ANALYTICS FOR ENHANCED STATS SCREEN ---

  // 1. Weekly Spending Pattern (Mon-Sun)
  List<double> getCustomerWeeklyPattern(String phone) {
    List<double> weeklySpending = List.filled(7, 0.0); // Mon (0) to Sun (6)
    
    for (var t in _transactions) {
      if (t.customerPhone == phone || phone == 'demo') {
        int dayIndex = t.timestamp.weekday - 1;
        weeklySpending[dayIndex] += t.totalAmount;
      }
    }
    return weeklySpending;
  }

  // 2. Hourly Shopping Habits (0-23 hours)
  List<double> getCustomerHourlyPattern(String phone) {
    List<double> hourlyActivity = List.filled(24, 0.0);
    
    for (var t in _transactions) {
      if (t.customerPhone == phone || phone == 'demo') {
        int hour = t.timestamp.hour;
        hourlyActivity[hour] += 1; // Count visits
      }
    }
    return hourlyActivity;
  }

  // 3. Top Brands Analysis
  Map<String, double> getCustomerTopBrands(String phone) {
    Map<String, double> brandSpending = {};
    for (var t in _transactions) {
      if (t.customerPhone == phone || phone == 'demo') {
        for (var item in t.items) {
          brandSpending[item.product.brand] = (brandSpending[item.product.brand] ?? 0) + item.totalPrice;
        }
      }
    }
    var sorted = brandSpending.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  // 4. Category Growth (This Month vs Last Month)
  Map<String, Map<String, double>> getCustomerCategoryGrowth(String phone) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(seconds: 1));

    Map<String, double> thisMonth = {};
    Map<String, double> lastMonth = {};

    for (var t in _transactions) {
      if (t.customerPhone == phone || phone == 'demo') {
        bool isThisMonth = t.timestamp.isAfter(thisMonthStart);
        bool isLastMonth = t.timestamp.isAfter(lastMonthStart) && t.timestamp.isBefore(lastMonthEnd);

        if (isThisMonth || isLastMonth) {
          for (var item in t.items) {
            String cat = item.product.category;
            if (isThisMonth) {
              thisMonth[cat] = (thisMonth[cat] ?? 0) + item.totalPrice;
            } else {
              lastMonth[cat] = (lastMonth[cat] ?? 0) + item.totalPrice;
            }
          }
        }
      }
    }
    return {'thisMonth': thisMonth, 'lastMonth': lastMonth};
  }

  // 5. Payment Method Distribution
  Map<String, int> getCustomerPaymentStats(String phone) {
    Map<String, int> stats = {};
    for (var t in _transactions) {
      if (t.customerPhone == phone || phone == 'demo') {
        stats[t.paymentMethod] = (stats[t.paymentMethod] ?? 0) + 1;
      }
    }
    return stats;
  }

  // 6. Savings Trend (Cumulative Mock Logic)
  List<Map<String, dynamic>> getCustomerSavingsTrend(String phone) {
     List<Map<String, dynamic>> trend = [];
     Map<int, double> savingsByMonth = {};
     for (var t in _transactions) {
       if (t.customerPhone == phone || phone == 'demo') {
         int monthKey = t.timestamp.month;
         double saving = t.totalAmount * 0.15; 
         savingsByMonth[monthKey] = (savingsByMonth[monthKey] ?? 0) + saving;
       }
     }
     for(int i=1; i<=12; i++) {
       if(savingsByMonth.containsKey(i)) {
         trend.add({'month': i, 'saving': savingsByMonth[i]});
       }
     }
     trend.sort((a,b) => (a['month'] as int).compareTo(b['month'] as int));
     return trend;
  }
  
  // 7. Purchase Frequency Heatmap (Day of Week vs Hour)
  List<Map<String, dynamic>> getCustomerPurchaseFrequency(String phone) {
    List<Map<String, dynamic>> points = [];
    Map<String, int> freqs = {};
    for (var t in _transactions) {
       if (t.customerPhone == phone || phone == 'demo') {
         String key = '${t.timestamp.weekday-1}_${t.timestamp.hour}';
         freqs[key] = (freqs[key] ?? 0) + 1;
       }
    }
    freqs.forEach((key, cnt) {
      var parts = key.split('_');
      points.add({
        'day': int.parse(parts[0]),
        'hour': int.parse(parts[1]),
        'count': cnt,
      });
    });
    return points;
  }

  // 8. Spending Forecast (Next 3 Months)
  List<double> getCustomerSpendingForecast(String phone) {
     double avgMonthly = predictCustomerMonthlyBill(phone);
     return [
       avgMonthly, 
       avgMonthly * (1 + (math.Random().nextDouble() * 0.1)), 
       avgMonthly * (1 - (math.Random().nextDouble() * 0.05)), 
     ];
  }


  void addDemoData(String shopId, [String? userPhone]) {
    // Clear existing transactions for fresh demo data
    _transactions.clear();

    final shopProducts = mockProducts.toList();
    
    if (shopProducts.isEmpty) return;
    
    // Use provided userPhone or default to 'demo'
    final targetPhone = userPhone ?? 'demo';
    
    // Group products by category
    Map<String, List<ProductModel>> productsByCategory = {};
    for (var product in shopProducts) {
      if (!productsByCategory.containsKey(product.category)) {
        productsByCategory[product.category] = [];
      }
      productsByCategory[product.category]!.add(product);
    }
    
    final categories = productsByCategory.keys.toList();
    final paymentMethods = ['Cash', 'UPI', 'Card'];
    final random = math.Random();
    
    // Create multiple customer profiles with different shopping patterns
    final customerProfiles = [
      {'phone': '9876543210', 'avgSpend': 500, 'frequency': 0.8, 'preferredCategories': ['Vegetables', 'Fruits', 'Dairy']},
      {'phone': '9876543211', 'avgSpend': 1200, 'frequency': 0.6, 'preferredCategories': ['Snacks', 'Beverages', 'Bakery']},
      {'phone': '9876543212', 'avgSpend': 800, 'frequency': 0.9, 'preferredCategories': ['Groceries', 'Spices', 'Pulses']},
      {'phone': '9876543213', 'avgSpend': 1500, 'frequency': 0.5, 'preferredCategories': ['Personal Care', 'Household', 'Baby Care']},
      {'phone': '9876543214', 'avgSpend': 600, 'frequency': 0.7, 'preferredCategories': ['Dairy', 'Eggs', 'Bread']},
      {'phone': 'demo', 'avgSpend': 2000, 'frequency': 1.0, 'preferredCategories': categories}, // Demo user with all categories
    ];
    
    // Generate transactions for the past 60 days
    for (int day = 0; day < 60; day++) {
      final date = DateTime.now().subtract(Duration(days: day));
      final isWeekend = date.weekday >= 6;
      final isMonthStart = date.day <= 5;
      final isMonthEnd = date.day >= 25;
      
      // More transactions on weekends and month-end
      int baseTransactions = 5 + random.nextInt(8);
      if (isWeekend) baseTransactions += 8;
      if (isMonthEnd) baseTransactions += 5;
      if (isMonthStart) baseTransactions += 3;
      
      for (int txn = 0; txn < baseTransactions; txn++) {
        // Select a customer (higher chance for frequent shoppers)
        final customer = customerProfiles[random.nextInt(customerProfiles.length)];
        final frequency = customer['frequency'] as double;
        
        // Skip this transaction based on customer frequency
        if (random.nextDouble() > frequency) continue;
        
        final timestamp = date.subtract(Duration(
          hours: 8 + random.nextInt(13), // 8 AM - 9 PM
          minutes: random.nextInt(60),
        ));
        
        Map<ProductModel, int> cart = {};
        final avgSpend = customer['avgSpend'] as int;
        final preferredCategories = customer['preferredCategories'] as List<String>;
        
        // Determine number of items based on average spend
        int numItems = 2 + random.nextInt(8);
        if (avgSpend > 1000) numItems += 3;
        
        double currentTotal = 0;
        int attempts = 0;
        
        while (currentTotal < avgSpend * 0.7 && attempts < numItems * 2) {
          attempts++;
          
          // 70% chance to pick from preferred categories
          String category;
          if (random.nextDouble() < 0.7 && preferredCategories.isNotEmpty) {
            category = preferredCategories[random.nextInt(preferredCategories.length)];
          } else {
            category = categories[random.nextInt(categories.length)];
          }
          
          if (!productsByCategory.containsKey(category)) continue;
          final categoryProducts = productsByCategory[category]!;
          if (categoryProducts.isEmpty) continue;
          
          final product = categoryProducts[random.nextInt(categoryProducts.length)];
          
          // Quantity based on product type and customer spending
          int quantity = 1;
          if (product.category == 'Vegetables' || product.category == 'Fruits') {
            quantity = 1 + random.nextInt(4); // 1-4 kg
          } else if (product.category == 'Snacks' || product.category == 'Beverages') {
            quantity = 1 + random.nextInt(3); // 1-3 items
          } else {
            quantity = 1 + random.nextInt(2); // 1-2 items
          }
          
          // Avoid duplicates, or increase quantity
          if (cart.containsKey(product)) {
            cart[product] = cart[product]! + quantity;
          } else {
            cart[product] = quantity;
          }
          
          currentTotal += product.price * quantity;
        }
        
        if (cart.isEmpty) continue;
        
        final saleItems = cart.entries.map((e) => SaleItem(
          product: e.key,
          quantity: e.value,
          unitPrice: e.key.price,
          costPrice: e.key.price * (0.7 + random.nextDouble() * 0.2), // 70-90% cost
        )).toList();
        
        // Payment method preference varies by customer
        String paymentMethod;
        if (avgSpend > 1000) {
          paymentMethod = random.nextDouble() < 0.7 ? 'UPI' : 'Card'; // High spenders prefer digital
        } else {
          paymentMethod = paymentMethods[random.nextInt(3)]; // Random for others
        }
        
        _transactions.add(SaleTransaction(
          id: '${timestamp.millisecondsSinceEpoch}_$txn',
          shopId: shopId,
          timestamp: timestamp,
          items: saleItems,
          paymentMethod: paymentMethod,
          customerPhone: targetPhone,
        ));
      }
    }
    
    // Add some high-value transactions for dramatic effect
    for (int i = 0; i < 5; i++) {
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      final timestamp = date.subtract(Duration(
        hours: 10 + random.nextInt(8),
        minutes: random.nextInt(60),
      ));
      
      Map<ProductModel, int> cart = {};
      
      // Add 10-15 items for a big shopping trip
      for (int j = 0; j < 10 + random.nextInt(6); j++) {
        final category = categories[random.nextInt(categories.length)];
        if (!productsByCategory.containsKey(category)) continue;
        final categoryProducts = productsByCategory[category]!;
        if (categoryProducts.isEmpty) continue;
        
        final product = categoryProducts[random.nextInt(categoryProducts.length)];
        final quantity = 2 + random.nextInt(4);
        
        if (cart.containsKey(product)) {
          cart[product] = cart[product]! + quantity;
        } else {
          cart[product] = quantity;
        }
      }
      
      if (cart.isEmpty) continue;
      
      final saleItems = cart.entries.map((e) => SaleItem(
        product: e.key,
        quantity: e.value,
        unitPrice: e.key.price,
        costPrice: e.key.price * 0.75,
      )).toList();
      
      _transactions.add(SaleTransaction(
        id: '${timestamp.millisecondsSinceEpoch}_big',
        shopId: shopId,
        timestamp: timestamp,
        items: saleItems,
        paymentMethod: 'Card',
        customerPhone: targetPhone,
      ));
    }
    
    notifyListeners();
  }
}
