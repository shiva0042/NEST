import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';

class ProductTypeStep extends StatelessWidget {
  const ProductTypeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.productTypes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final type = provider.productTypes[index];
        return ListTile(
          title: Text(type),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => provider.selectProductType(type),
        );
      },
    );
  }
}
