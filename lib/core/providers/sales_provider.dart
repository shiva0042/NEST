import 'package:flutter/material.dart';
import '../../features/map_discovery/models/product_model.dart';

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
  
  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get totalProfit => items.fold(0, (sum, item) => sum + item.profit);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

// Low Stock Alert
class LowStockAlert {
  final ProductModel product;
  final int currentStock;
  final int threshold;
  final DateTime alertTime;
  
  LowStockAlert({
    required this.product,
    required this.currentStock,
    this.threshold = 10,
    DateTime? alertTime,
  }) : alertTime = alertTime ?? DateTime.now();
  
  bool get isCritical => currentStock <= 5;
}

// Analytics Summary
class AnalyticsSummary {
  final double totalRevenue;
  final double totalProfit;
  final int totalTransactions;
  final int totalItemsSold;
  final Map<String, double> revenueByCategory;
  final Map<String, int> salesByProduct;
  final Map<String, double> revenueByBrand;
  final Map<String, int> salesByCategory; // Units sold per category
  final Map<String, Map<String, int>> brandsByCategory; // Top brands in each category
  final Map<String, Map<String, double>> revenueBrandsByCategory; // Revenue by brand in each category
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

// Sales Provider - Manages all sales and analytics
class SalesProvider extends ChangeNotifier {
  final List<SaleTransaction> _transactions = [];
  final List<LowStockAlert> _lowStockAlerts = [];
  static const int lowStockThreshold = 10;
  
  List<SaleTransaction> get transactions => List.unmodifiable(_transactions);
  List<LowStockAlert> get lowStockAlerts => List.unmodifiable(_lowStockAlerts);
  
  // Record a new sale
  void recordSale({
    required String shopId,
    required Map<ProductModel, int> cartItems,
    String? customerPhone,
    String paymentMethod = 'Cash',
  }) {
    final saleItems = cartItems.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      
      // Assume cost price is 80% of selling price for demo
      final costPrice = product.price * 0.8;
      
      return SaleItem(
        product: product,
        quantity: quantity,
        unitPrice: product.price,
        costPrice: costPrice,
      );
    }).toList();
    
    final transaction = SaleTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      shopId: shopId,
      timestamp: DateTime.now(),
      items: saleItems,
      customerPhone: customerPhone,
      paymentMethod: paymentMethod,
    );
    
    _transactions.add(transaction);
    
    // Update stock and check for low stock
    _updateInventoryAndCheckAlerts(cartItems, shopId);
    
    notifyListeners();
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
  
  // Get daily revenue data for charts (last 7 days)
  List<Map<String, dynamic>> getDailyRevenueData(String shopId) {
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
      
      final revenue = dayTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);
      
      data.add({
        'day': _getDayName(date.weekday),
        'date': date,
        'revenue': revenue,
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
  
  // Get top selling products
  List<MapEntry<String, int>> getTopProducts(String shopId, {int limit = 5}) {
    final analytics = getMonthAnalytics(shopId);
    final sorted = analytics.salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
  
  // Get top brands
  List<MapEntry<String, double>> getTopBrands(String shopId, {int limit = 5}) {
    final analytics = getMonthAnalytics(shopId);
    final sorted = analytics.revenueByBrand.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
  
  // Add demo data for testing - includes ALL categories
  void addDemoData(String shopId) {
    final shopProducts = mockProducts.where((p) => p.shopId == shopId).toList();
    
    if (shopProducts.isEmpty) return;
    
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
    
    // Create demo transactions for the past 7 days
    // Each day will have multiple transactions covering different categories
    for (int day = 0; day < 7; day++) {
      // 5-10 transactions per day
      int transactionsPerDay = 5 + (day * 2 % 6);
      
      for (int txn = 0; txn < transactionsPerDay; txn++) {
        final timestamp = DateTime.now().subtract(Duration(
          days: day,
          hours: 9 + txn * 2, // Between 9 AM to evening
          minutes: (txn * 17) % 60,
        ));
        
        Map<ProductModel, int> cart = {};
        
        // Select 2-5 items from different categories
        int numItems = 2 + (txn + day) % 4;
        Set<String> usedCategories = {};
        
        for (int i = 0; i < numItems; i++) {
          // Pick a category (try to diversify)
          String category;
          if (usedCategories.length < categories.length) {
            // Find an unused category
            category = categories.firstWhere(
              (c) => !usedCategories.contains(c),
              orElse: () => categories[(txn + i) % categories.length],
            );
          } else {
            category = categories[(txn + i + day) % categories.length];
          }
          usedCategories.add(category);
          
          // Pick a product from this category
          final categoryProducts = productsByCategory[category]!;
          final product = categoryProducts[(txn + i + day) % categoryProducts.length];
          
          // Random quantity 1-5
          int quantity = 1 + (txn + i + day) % 5;
          cart[product] = quantity;
        }
        
        final saleItems = cart.entries.map((e) => SaleItem(
          product: e.key,
          quantity: e.value,
          unitPrice: e.key.price,
          costPrice: e.key.price * 0.8,
        )).toList();
        
        _transactions.add(SaleTransaction(
          id: '${timestamp.millisecondsSinceEpoch}_$txn',
          shopId: shopId,
          timestamp: timestamp,
          items: saleItems,
          paymentMethod: paymentMethods[(txn + day) % 3],
          customerPhone: txn % 3 == 0 ? '98765${10000 + txn}' : null,
        ));
      }
    }
    
    // Add some transactions for today with more variety
    final todayCategories = categories.take(categories.length).toList();
    for (int hour = 0; hour < 6; hour++) {
      final timestamp = DateTime.now().subtract(Duration(hours: hour, minutes: hour * 10));
      
      Map<ProductModel, int> cart = {};
      
      // Use 3-4 different categories per transaction
      for (int i = 0; i < 3 + hour % 2; i++) {
        final category = todayCategories[(hour + i) % todayCategories.length];
        final categoryProducts = productsByCategory[category]!;
        final product = categoryProducts[hour % categoryProducts.length];
        cart[product] = 1 + hour % 4;
      }
      
      final saleItems = cart.entries.map((e) => SaleItem(
        product: e.key,
        quantity: e.value,
        unitPrice: e.key.price,
        costPrice: e.key.price * 0.8,
      )).toList();
      
      _transactions.add(SaleTransaction(
        id: '${timestamp.millisecondsSinceEpoch}_today_$hour',
        shopId: shopId,
        timestamp: timestamp,
        items: saleItems,
        paymentMethod: paymentMethods[hour % 3],
      ));
    }
    
    notifyListeners();
  }
}
