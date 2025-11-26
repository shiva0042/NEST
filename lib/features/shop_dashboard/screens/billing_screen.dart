import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  // Products available to sell (Shop 1)
  late List<ProductModel> _availableProducts;
  // Cart: Map of Product -> Quantity
  final Map<ProductModel, int> _cart = {};
  
  String _searchQuery = '';
  final TextEditingController _customerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final shopId = context.read<StoreProvider>().currentShopId;
    _availableProducts = mockProducts.where((p) => p.shopId == shopId).toList();
  }

  double get _totalAmount {
    double total = 0;
    _cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  void _addToCart(ProductModel product) {
    setState(() {
      if (_cart.containsKey(product)) {
        _cart[product] = _cart[product]! + 1;
      } else {
        _cart[product] = 1;
      }
    });
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

    final StringBuffer billText = StringBuffer();
    billText.writeln('*Fresh Mart Bill*');
    billText.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    billText.writeln('----------------');
    
    _cart.forEach((product, quantity) {
      billText.writeln('${product.name} x $quantity = ₹${(product.price * quantity).toStringAsFixed(0)}');
    });
    
    billText.writeln('----------------');
    billText.writeln('*Total: ₹${_totalAmount.toStringAsFixed(0)}*');
    billText.writeln('Thank you for shopping with us!');

    final String message = Uri.encodeComponent(billText.toString());
    final String phone = _customerPhoneController.text.trim();
    
    final Uri url = phone.isNotEmpty 
        ? Uri.parse('https://wa.me/$phone?text=$message')
        : Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void _printBill() {
    // Placeholder for printing functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Print Bill'),
        content: Text('Sending bill to printer...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('New Bill', style: TextStyle(color: AppColors.text)),
        iconTheme: IconThemeData(color: AppColors.text),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          // Product List
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final inCart = _cart.containsKey(product);
                final quantity = _cart[product] ?? 0;

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(product.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                  ),
                  title: Text(product.name),
                  subtitle: Text('₹${product.price.toStringAsFixed(0)} | Stock: ${product.stockQuantity}'),
                  trailing: inCart
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeFromCart(product),
                            ),
                            Text('$quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () => _addToCart(product),
                            ),
                          ],
                        )
                      : IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _addToCart(product),
                        ),
                );
              },
            ),
          ),
          
          // Cart Summary
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Items: ${_cart.length}',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _customerPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Customer Phone (Optional for WhatsApp)',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _completeSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Complete Sale',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _completeSale() {
    // Deduct stock
    _cart.forEach((product, quantity) {
      final index = mockProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final currentStock = mockProducts[index].stockQuantity;
        final newStock = currentStock - quantity;
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
        );
      }
    });

    // Show success and options
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Sale Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock has been updated.'),
            SizedBox(height: 16),
            Text('Total: ₹${_totalAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _printBill();
            },
            icon: Icon(Icons.print),
            label: Text('Print'),
          ),
          TextButton.icon(
            onPressed: () {
              _sendBillWhatsApp();
            },
            icon: Icon(Icons.send),
            label: Text('WhatsApp'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _cart.clear();
                _customerPhoneController.clear();
                // Refresh available products to show updated stock
                final shopId = context.read<StoreProvider>().currentShopId;
                _availableProducts = mockProducts.where((p) => p.shopId == shopId).toList();
              });
              Navigator.pop(context);
            },
            child: Text('New Bill'),
          ),
        ],
      ),
    );
  }
}
