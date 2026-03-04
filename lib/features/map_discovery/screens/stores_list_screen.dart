import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../models/shop_model.dart';
import 'shop_details_view.dart';

class StoresListScreen extends StatelessWidget {
  const StoresListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<StoreProvider>().shops;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Stores',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find the best shops around you (${shops.length} stores)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<StoreProvider>().fetchShops();
                },
                child: shops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_rounded, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                            SizedBox(height: 16),
                            Text(
                              'No stores found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pull down to refresh',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          final shop = shops[index];
                          return _StoreListCard(shop: shop);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreListCard extends StatelessWidget {
  final ShopModel shop;

  const _StoreListCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopDetailsView(shop: shop)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    shop.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.background,
                      child: const Icon(Icons.store, color: AppColors.textLight),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.delivery_dining_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${shop.distance} km',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    ),
  );
  }
}
