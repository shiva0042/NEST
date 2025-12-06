import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void _loadProducts() {
    final shopId = context.read<StoreProvider>().currentShopId;
    _availableProducts = mockProducts.where((p) => p.shopId == shopId && p.inStock).toList();
  }

  double get _totalAmount {
    double total = 0;
    _cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  int get _totalItems {
    return _cart.values.fold(0, (sum, qty) => sum + qty);
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
      body: Row(
        children: [
          // Product List (Left Side)
          Expanded(
            flex: 3,
            child: Column(
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
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                      childAspectRatio: 0.85,
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
                              color: inCart ? AppColors.primary : AppColors.border,
                              width: inCart ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                                    // Stock Badge
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLowStock 
                                              ? Colors.orange.withOpacity(0.9)
                                              : Colors.green.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${product.stockQuantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Quantity Overlay
                                    if (inCart)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'x$quantity',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${product.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
            ),
          ),
          
          // Cart Summary (Right Side)
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(left: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                // Cart Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Cart',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_totalItems items',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                
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
                              Text('Tap products to add', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
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
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '₹${product.price.toStringAsFixed(0)} × $quantity = ₹${(product.price * quantity).toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red[300], size: 22),
                                    onPressed: () => _removeFromCart(product),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 22),
                                    onPressed: () => _addToCart(product),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // Cart Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Payment Method
                      Row(
                        children: [
                          const Text('Payment:', style: TextStyle(color: AppColors.textLight)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'Cash', label: Text('Cash', style: TextStyle(fontSize: 11))),
                                ButtonSegment(value: 'UPI', label: Text('UPI', style: TextStyle(fontSize: 11))),
                                ButtonSegment(value: 'Card', label: Text('Card', style: TextStyle(fontSize: 11))),
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
                      const SizedBox(height: 12),
                      
                      // Phone Input
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _customerPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Phone (for WhatsApp)',
                            hintStyle: TextStyle(fontSize: 13),
                            prefixIcon: Icon(Icons.phone, size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Complete Sale Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _cart.isEmpty ? null : _completeSale,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded),
                              SizedBox(width: 8),
                              Text('Complete Sale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
