import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/store_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/category_step.dart';
import '../widgets/subcategory_step.dart';
import '../widgets/product_type_step.dart';
import '../widgets/brand_step.dart';
import '../widgets/variant_step.dart';
import 'custom_product_screen.dart';

class ProductOnboardingScreen extends StatelessWidget {
  const ProductOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Add Your Products"),
              leading: provider.currentStep > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // Handle back navigation in steps
                        // Ideally implemented in provider to go back one step
                        // For now, just pop if it's 0, or reset/decrement step
                        if (provider.currentStep == 0) {
                          Navigator.pop(context);
                        } else {
                          provider.previousStep();
                        }
                      },
                    )
                  : null,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => _showBatchReview(context, provider),
                    ),
                    if (provider.batchProducts.isNotEmpty)
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
                            '${provider.batchProducts.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomProductScreen()),
                    );
                  },
                  child: const Text("Add Custom"),
                )
              ],
            ),
            body: Column(
              children: [
                // Progress Indicator
                LinearProgressIndicator(
                  value: (provider.currentStep + 1) / 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Expanded(
                  child: _buildStep(provider.currentStep),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBatchReview(BuildContext context, OnboardingProvider provider) {
    if (provider.batchProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Review Cart (${provider.batchProducts.length})",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.batchProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = provider.batchProducts[index];
                      final marketPrice = (product.sizeValue * 0.2).clamp(10.0, 500.0).roundToDouble();
                      
                      return Dismissible(
                        key: Key(product.id),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) {
                          provider.removeFromBatch(product.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[100]),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.canonicalName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Market: ₹$marketPrice", style: TextStyle(color: Colors.green[700], fontSize: 12)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: (provider.selectedProductPrices[product.id] ?? marketPrice).toStringAsFixed(0),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixText: "₹",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    final price = double.tryParse(value) ?? 0.0;
                                    provider.setPrice(product.id, price);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // Ensure prices are set for all items
                      for (var p in provider.batchProducts) {
                        if (!provider.selectedProductPrices.containsKey(p.id)) {
                           final marketPrice = (p.sizeValue * 0.2).clamp(10.0, 500.0).roundToDouble();
                           provider.setPrice(p.id, marketPrice);
                        }
                      }
                      
                      // Get Shop ID
                      final shopId = context.read<StoreProvider>().currentShopId;
                      await provider.saveBatch(shopId);
                      
                      if (context.mounted) {
                        Navigator.pop(context); // Close sheet
                        Navigator.pop(context); // Close Onboarding Screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added ${provider.batchProducts.length} items to inventory!")),
                        );
                      }
                    },
                    child: const Text("Confirm & Add All to Inventory"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const CategoryStep();
      case 1:
        return const SubcategoryStep();
      case 2:
        return const ProductTypeStep();
      case 3:
        return const BrandStep();
      case 4:
        return const VariantStep();
      default:
        return const CategoryStep();
    }
  }
}
