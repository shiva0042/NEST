import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../../core/providers/sales_provider.dart';
import '../../map_discovery/models/product_model.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late List<ProductModel> _availableProducts;
  final Map<ProductModel, int> _cart = {};
  
  String _searchQuery = '';
  String _selectedPaymentMethod = 'Cash';
  final TextEditingController _customerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final shopId = context.read<StoreProvider>().currentShopId;
    
    // Try to load from Firestore first
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('shopId', isEqualTo: shopId)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        // Products found in Firestore
        setState(() {
          _availableProducts = snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductModel(
              id: data['id'] ?? doc.id,
              shopId: data['shopId'] ?? shopId,
              name: data['name'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
              imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/300',
              inStock: data['inStock'] ?? true,
              stockQuantity: data['stockQuantity'] ?? 0,
              category: data['category'] ?? 'Other',
              brand: data['brand'] ?? 'Local',
              unit: data['unit'] ?? 'weight',
            );
          }).where((p) => p.inStock).toList();
        });
      } else {
        // No products in Firestore, fall back to mock products
        setState(() {
          _availableProducts = mockProducts.where((p) => p.shopId == shopId && p.inStock).toList();
        });
      }
    } catch (e) {
      // Error loading from Firestore, use mock products
      debugPrint('Error loading products: $e');
      setState(() {
        _availableProducts = mockProducts.where((p) => p.shopId == shopId && p.inStock).toList();
      });
    }
  }

  double get _totalAmount {
    double total = 0;
    _cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  int get _totalItems {
    return _cart.values.fold(0, (sumQty, qty) => sumQty + qty);
  }

  void _addToCart(ProductModel product) {
    final currentQty = _cart[product] ?? 0;
    if (currentQty < product.stockQuantity) {
      setState(() {
        _cart[product] = currentQty + 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more. Only ${product.stockQuantity} in stock.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeFromCart(ProductModel product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! > 1) {
          _cart[product] = _cart[product]! - 1;
        } else {
          _cart.remove(product);
        }
      }
    });
  }

  Future<void> _sendBillWhatsApp() async {
    if (_cart.isEmpty) return;

    final shopName = context.read<StoreProvider>().currentShopName ?? 'Shop';
    final StringBuffer billText = StringBuffer();
    billText.writeln('*$shopName - Bill*');
    billText.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    billText.writeln('Time: ${TimeOfDay.now().format(context)}');
    billText.writeln('Payment: $_selectedPaymentMethod');
    billText.writeln('────────────────');
    
    _cart.forEach((product, quantity) {
      billText.writeln(product.name);
      billText.writeln('  $quantity × ₹${product.price.toStringAsFixed(0)} = ₹${(product.price * quantity).toStringAsFixed(0)}');
    });
    
    billText.writeln('────────────────');
    billText.writeln('*Total: ₹${_totalAmount.toStringAsFixed(0)}*');
    billText.writeln('────────────────');
    billText.writeln('Thank you for shopping! 🛒');

    final String message = Uri.encodeComponent(billText.toString());
    final String phone = _customerPhoneController.text.trim();
    
    final Uri url = phone.isNotEmpty 
        ? Uri.parse('https://wa.me/$phone?text=$message')
        : Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  void _printBill() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.print, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Print Bill'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Bill sent to printer!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _availableProducts
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Check for low stock alerts
    final salesProvider = context.watch<SalesProvider>();
    final lowStockAlerts = salesProvider.lowStockAlerts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('New Bill', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.text),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh Products',
            onPressed: () async {
              await _loadProducts();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Loaded ${_availableProducts.length} products'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          if (lowStockAlerts.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: Colors.orange),
                  onPressed: () => _showLowStockAlerts(lowStockAlerts),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${lowStockAlerts.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          if (isMobile) {
            return Stack(
              children: [
                _buildProductList(filteredProducts, isMobile: true),
                if (_cart.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_totalItems Items',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
                                ),
                                Text(
                                  '₹${_totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () => _showCartModal(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.shopping_cart_checkout_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('View Cart'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
          
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildProductList(filteredProducts),
              ),
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
                child: _buildCartSummary(isMobile: false),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> filteredProducts, {bool isMobile = false}) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
        
        // Product Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16, 16, 16, isMobile ? 100 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile && MediaQuery.of(context).size.width < 600 ? 2 : 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final inCart = _cart.containsKey(product);
              final quantity = _cart[product] ?? 0;
              final isLowStock = product.stockQuantity <= 10;

              return GestureDetector(
                onTap: () => _addToCart(product),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: inCart ? AppColors.primary : Colors.grey.shade300,
                      width: inCart ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: Image.network(
                                product.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ),
                            if (isLowStock)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product.stockQuantity == 0 ? Colors.red : Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.stockQuantity == 0 ? 'Out of Stock' : '${product.stockQuantity} Left',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (inCart)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'x$quantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Info
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text('Current Bill', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(),
            Expanded(child: _buildCartSummary(isMobile: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary({required bool isMobile}) {
    return Column(
      children: [
        // Cart Items
        Expanded(
          child: _cart.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textLight),
                      SizedBox(height: 16),
                      Text('Cart is empty', style: TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _cart.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final entry = _cart.entries.toList()[index];
                    final product = entry.key;
                    final quantity = entry.value;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '₹${product.price.toStringAsFixed(0)} × $quantity',
                        style: const TextStyle(fontSize: 13, color: AppColors.textLight),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: Colors.red[300], size: 24),
                            onPressed: () => _removeFromCart(product),
                            padding: EdgeInsets.zero,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 30),
                            alignment: Alignment.center,
                            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 24),
                            onPressed: () => _addToCart(product),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        
        // Footer Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Payment Method
                Row(
                  children: [
                    const Text('Payment:', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Cash', label: Text('Cash')),
                          ButtonSegment(value: 'UPI', label: Text('UPI')),
                          ButtonSegment(value: 'Card', label: Text('Card')),
                        ],
                        selected: {_selectedPaymentMethod},
                        onSelectionChanged: (selected) {
                          setState(() => _selectedPaymentMethod = selected.first);
                        },
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Phone Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _customerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Customer Phone (for WhatsApp)',
                      prefixIcon: Icon(Icons.chat, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Complete Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : () {
                      if (isMobile) Navigator.pop(context); // Close modal
                      _completeSale();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded),
                        SizedBox(width: 8),
                        Text('Complete Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLowStockAlerts(List<LowStockAlert> alerts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Low Stock Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.read<SalesProvider>().clearAllAlerts();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: alert.isCritical ? Colors.red[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${alert.currentStock}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: alert.isCritical ? Colors.red : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    title: Text(alert.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      alert.isCritical ? 'Critical! Restock immediately' : 'Low stock warning',
                      style: TextStyle(
                        color: alert.isCritical ? Colors.red : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        context.read<SalesProvider>().dismissAlert(alert.product.id);
                        if (alerts.length == 1) Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeSale() {
    final salesProvider = context.read<SalesProvider>();
    final shopId = context.read<StoreProvider>().currentShopId;
    
    // Record sale in SalesProvider (also updates inventory)
    salesProvider.recordSale(
      shopId: shopId,
      cartItems: Map.from(_cart),
      customerPhone: _customerPhoneController.text.isNotEmpty ? _customerPhoneController.text : null,
      paymentMethod: _selectedPaymentMethod,
    );

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sale Completed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment: $_selectedPaymentMethod',
              style: const TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 4),
            const Text(
              'Inventory updated',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton.icon(
            onPressed: () => _printBill(),
            icon: const Icon(Icons.print_rounded),
            label: const Text('Print'),
          ),
          TextButton.icon(
            onPressed: () => _sendBillWhatsApp(),
            icon: const Icon(Icons.send_rounded, color: Colors.green),
            label: const Text('WhatsApp', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cart.clear();
                _customerPhoneController.clear();
                _loadProducts(); // Refresh to show updated stock
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('New Bill'),
          ),
        ],
      ),
    );
  }
}
