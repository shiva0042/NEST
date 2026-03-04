import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Blob 1
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [const Color(0xFFFF9800).withOpacity(0.1), Colors.transparent]
                    : [Colors.orange.withOpacity(0.15), Colors.transparent],
              ),
            ),
          ),
        ),
        
        // 2. Blob 2
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [AppColors.primary.withOpacity(0.15), Colors.transparent]
                    : [Colors.blue.withOpacity(0.2), Colors.transparent],
              ),
            ),
          ),
        ),

        // 3. Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
             backgroundColor: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cart',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Delivery in 10 mins',
                  style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
          body: Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.itemCount == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add items to start a cart',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Items
                    ...cart.items.values.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[100]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${item.product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                  onPressed: () => cart.removeItem(item.product.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32),
                                ),
                                Text(item.quantity.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                  onPressed: () => cart.addItem(item.product, size: item.selectedSize),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    
                    const Divider(height: 32),

                    // Bill Details
                    const Text('Bill Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _BillRow(label: 'Item Total', value: '₹${cart.totalAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    const _BillRow(label: 'Delivery Fee', value: '₹30'),
                    const SizedBox(height: 8),
                    const _BillRow(label: 'Platform Fee', value: '₹0'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                    _BillRow(label: 'To Pay', value: '₹${(cart.totalAmount + 30).toStringAsFixed(0)}', isBold: true),
                    
                    const SizedBox(height: 24),

                    // Checkout Button wrapped in a safe block
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Order Placed!'),
                            content: const Text('Your order will be delivered soon.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  cart.clear();
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                },
                                child: const Text('Done'),
                              )
                            ],
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '₹${(cart.totalAmount + 30).toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Text('TOTAL', style: TextStyle(fontSize: 10, color: Colors.white70)),
                            ],
                          ),
                          const Row(
                            children: [
                              Text('Place Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _BillRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold 
                ? (isDark ? Colors.white : Colors.black) 
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold 
                ? (isDark ? Colors.white : Colors.black) 
                : (isDark ? Colors.grey[300] : Colors.grey[800]),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
