import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/map_discovery/models/shop_model.dart';
import '../features/map_discovery/models/product_model.dart';

/// Script to seed Firestore with mock data
/// Run this once to populate your Firestore database with shops and products
class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> seedDatabase() async {
    print('🌱 Starting Firestore seeding...\n');
    
    try {
      // Seed shops
      await _seedShops();
      
      // Seed products
      await _seedProducts();
      
      print('\n✅ Firestore seeding completed successfully!');
      print('   - ${mockShops.length} shops added');
      print('   - ${mockProducts.length} products added');
    } catch (e) {
      print('❌ Error seeding Firestore: $e');
    }
  }
  
  Future<void> _seedShops() async {
    print('📦 Seeding shops...');
    final batch = _firestore.batch();
    int count = 0;
    
    for (var shop in mockShops) {
      final docRef = _firestore.collection(ShopModel.collectionName).doc(shop.id);
      batch.set(docRef, shop.toMap());
      count++;
    }
    
    await batch.commit();
    print('   ✓ Added $count shops');
  }
  
  Future<void> _seedProducts() async {
    print('📦 Seeding products...');
    
    // Firestore has a limit of 500 operations per batch
    // So we need to split into multiple batches
    final batches = <WriteBatch>[];
    var currentBatch = _firestore.batch();
    int operationCount = 0;
    int totalCount = 0;
    
    for (var product in mockProducts) {
      final docRef = _firestore.collection('products').doc(product.id);
      currentBatch.set(docRef, {
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
      
      operationCount++;
      totalCount++;
      
      // Firestore batch limit is 500 operations
      if (operationCount >= 500) {
        batches.add(currentBatch);
        currentBatch = _firestore.batch();
        operationCount = 0;
      }
    }
    
    // Add the last batch if it has any operations
    if (operationCount > 0) {
      batches.add(currentBatch);
    }
    
    // Commit all batches
    print('   ℹ️  Committing ${batches.length} batches...');
    for (int i = 0; i < batches.length; i++) {
      await batches[i].commit();
      print('   ✓ Batch ${i + 1}/${batches.length} committed');
    }
    
    print('   ✓ Added $totalCount products');
  }
  
  /// Clear all data (use with caution!)
  Future<void> clearDatabase() async {
    print('🗑️  Clearing Firestore database...');
    
    try {
      // Clear shops
      final shopsSnapshot = await _firestore.collection(ShopModel.collectionName).get();
      final shopsBatch = _firestore.batch();
      for (var doc in shopsSnapshot.docs) {
        shopsBatch.delete(doc.reference);
      }
      await shopsBatch.commit();
      print('   ✓ Cleared ${shopsSnapshot.docs.length} shops');
      
      // Clear products (in batches due to large number)
      final productsSnapshot = await _firestore.collection('products').get();
      var productBatch = _firestore.batch();
      int count = 0;
      
      for (var doc in productsSnapshot.docs) {
        productBatch.delete(doc.reference);
        count++;
        
        if (count >= 500) {
          await productBatch.commit();
          productBatch = _firestore.batch();
          count = 0;
        }
      }
      
      if (count > 0) {
        await productBatch.commit();
      }
      
      print('   ✓ Cleared ${productsSnapshot.docs.length} products');
      print('✅ Database cleared successfully!');
    } catch (e) {
      print('❌ Error clearing database: $e');
    }
  }
}
