import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/map_discovery/models/shop_model.dart';
import '../../features/map_discovery/models/product_model.dart';
import '../../core/constants/app_colors.dart';

class DatabaseSeedScreen extends StatefulWidget {
  const DatabaseSeedScreen({super.key});

  @override
  State<DatabaseSeedScreen> createState() => _DatabaseSeedScreenState();
}

class _DatabaseSeedScreenState extends State<DatabaseSeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSeeding = false;
  String _status = 'Ready to upload data to Firestore';
  int _shopsUploaded = 0;
  int _productsUploaded = 0;

  Future<void> _seedDatabase() async {
    setState(() {
      _isSeeding = true;
      _status = 'Starting upload...';
      _shopsUploaded = 0;
      _productsUploaded = 0;
    });

    try {
      // Upload shops
      await _uploadShops();
      
      // Upload products
      await _uploadProducts();
      
      setState(() {
        _isSeeding = false;
        _status = '✅ Upload completed successfully!';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded $_shopsUploaded shops and $_productsUploaded products!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSeeding = false;
        _status = '❌ Error: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _uploadShops() async {
    setState(() => _status = 'Uploading shops...');
    
    final batch = _firestore.batch();
    
    for (var shop in mockShops) {
      final docRef = _firestore.collection(ShopModel.collectionName).doc(shop.id);
      batch.set(docRef, shop.toMap());
    }
    
    await batch.commit();
    
    setState(() {
      _shopsUploaded = mockShops.length;
      _status = 'Uploaded ${mockShops.length} shops. Now uploading products...';
    });
  }

  Future<void> _uploadProducts() async {
    // Split into batches (Firestore limit: 500 operations per batch)
    final totalProducts = mockProducts.length;
    int uploaded = 0;
    
    for (int i = 0; i < totalProducts; i += 500) {
      final batch = _firestore.batch();
      final end = (i + 500 < totalProducts) ? i + 500 : totalProducts;
      
      for (int j = i; j < end; j++) {
        final product = mockProducts[j];
        final docRef = _firestore.collection('products').doc(product.id);
        batch.set(docRef, {
          'id': product.id,
          'shopId': product.shopId,
          'name': product.name,
          'price': product.price,
          'originalPrice': product.originalPrice,
          'imageUrl': product.imageUrl,
          'inStock': product.inStock,
          'stockQuantity': product.stockQuantity,
          'category': product.category,
          'brand': product.brand,
          'unit': product.unit,
        });
      }
      
      await batch.commit();
      uploaded = end;
      
      setState(() {
        _productsUploaded = uploaded;
        _status = 'Uploaded $uploaded / $totalProducts products...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Data to Firestore'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_upload_rounded,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Shops & Products',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will upload all shops and products to your Firestore database.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shops:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${mockShops.length} shops'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${mockProducts.length} products'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_isSeeding) ...[
              LinearProgressIndicator(
                value: _productsUploaded > 0 ? _productsUploaded / mockProducts.length : null,
                backgroundColor: Colors.grey[300],
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              if (_shopsUploaded > 0)
                Text(
                  'Shops uploaded: $_shopsUploaded/${mockShops.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              if (_productsUploaded > 0)
                Text(
                  'Products uploaded: $_productsUploaded/${mockProducts.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
            ] else ...[
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _status.contains('✅') ? Colors.green : AppColors.text,
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _isSeeding ? null : _seedDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSeeding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Upload to Firestore',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
