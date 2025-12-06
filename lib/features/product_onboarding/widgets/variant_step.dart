import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class VariantStep extends StatelessWidget {
  const VariantStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.availableVariants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No products found for this selection."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Custom Product Screen
                Navigator.pushNamed(context, '/custom-product');
              },
              child: const Text("Add Custom Product"),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Select available sizes for ${provider.selectedBrand} ${provider.selectedProductType ?? provider.selectedSubcategory}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.availableVariants.length,
            itemBuilder: (context, index) {
              final product = provider.availableVariants[index];
              final isSelected = provider.selectedProductIds.contains(product.id);
              
              return InkWell(
                onTap: () => provider.toggleProductSelection(product.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product.canonicalSize,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.check, size: 16, color: Colors.white),
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
            onPressed: provider.selectedProductIds.isEmpty ? null : () {
              provider.addToBatch();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Added to Cart! Continue shopping.")),
              );
              // Go back to Brand selection (Step 3) to pick another brand or category
              // Or just pop to stay in flow? 
              // Let's go back to Brand step (index 3) so they can pick another brand easily
              // Actually, provider.previousStep() goes back one step.
              // Let's just notify and let them decide.
              // Or better, reset to Brand selection.
              // Ideally, we want to stay on the same screen or go up one level.
              // Let's go back to Brand list.
              provider.previousStep(); 
            },
            child: const Text("Add to Cart & Continue"),
          ),
        ),
      ],
    );
  }


}
