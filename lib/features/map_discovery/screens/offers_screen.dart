import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Community Deals',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(color: AppColors.surface),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Best offers near you',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 24),
                _OfferCard(
                  title: '50% OFF on Organic Veggies',
                  shopName: 'Green Valley Organics',
                  expiry: 'Expires in 2 hours',
                  color: Colors.green,
                  icon: Icons.eco_rounded,
                ),
                _OfferCard(
                  title: 'Buy 1 Get 1 Free: Bread',
                  shopName: 'Fresh Mart',
                  expiry: 'Valid today only',
                  color: Colors.orange,
                  icon: Icons.bakery_dining_rounded,
                ),
                _OfferCard(
                  title: 'Flash Sale: Dairy Products',
                  shopName: 'Daily Needs Store',
                  expiry: 'Ends at 8 PM',
                  color: Colors.blue,
                  icon: Icons.water_drop_rounded,
                ),
                _OfferCard(
                  title: '20% OFF on All Spices',
                  shopName: 'Spice World',
                  expiry: 'Valid until Sunday',
                  color: Colors.redAccent,
                  icon: Icons.whatshot_rounded,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String shopName;
  final String expiry;
  final Color color;
  final IconData icon;

  const _OfferCard({
    required this.title,
    required this.shopName,
    required this.expiry,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 150,
                color: color.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.store_rounded, size: 14, color: color),
                            SizedBox(width: 6),
                            Text(
                              shopName,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_rounded, size: 16, color: color),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.textLight, size: 18),
                      SizedBox(width: 6),
                      Text(
                        expiry,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
