import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../../../core/models/shop_models.dart';
import '../../../core/services/firebase_service.dart';
// import '../../map_discovery/models/product_model.dart'; // No longer needed
// import '../../../core/services/local_storage_service.dart'; // No longer needed

class CatalogService {

  
  // Dynamic Data Structures
  List<String> categories = [];
  Map<String, List<String>> subcategories = {}; // In JSON, "types" act as subcategories or product types.
  // The JSON structure is Category -> Types (which seem to be Product Types) -> Brands -> Variants -> Sizes
  // It doesn't strictly have "Subcategory" AND "Product Type". It has "types".
  // So we will map JSON "types" to our "Product Type" and maybe use Category as Subcategory if needed, 
  // or just flatten it.
  // Let's map:
  // Category -> JSON "name" (e.g., BISCUITS)
  // Subcategory -> JSON "types" (e.g., Glucose Biscuits) - actually these look like Product Types.
  // But our UI expects Category -> Subcategory -> Product Type.
  // We can treat the JSON "types" as Subcategories. And maybe Product Type is same as Subcategory or we skip it.
  // Let's try: Category -> Subcategory (JSON Type) -> Product Type (Same as Subcategory or generic)
  
  Map<String, List<String>> productTypes = {};
  List<String> brands = [];
  
  bool _isLoaded = false;



  // Load and Parse JSON
  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/consolidated_products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoryList = jsonData['categories'];

      final Set<String> allBrands = {};

      for (var catData in categoryList) {
        final String categoryName = catData['name'];
        categories.add(categoryName);
        
        final List<String> types = List<String>.from(catData['types'] ?? []);
        final List<String> catBrands = List<String>.from(catData['brands'] ?? []);
        // final List<String> variants = List<String>.from(catData['variants'] ?? []); // unused
        // final List<String> sizes = List<String>.from(catData['sizes'] ?? []); // unused

        subcategories[categoryName] = types;
        allBrands.addAll(catBrands);

        // Generate Products (Cartesian Product of Type x Brand x Variant x Size)
        // This might be huge, but for "Master Catalog" search/lookup it's okay.
        // However, for the UI "Wizard", we don't need to generate all combinations upfront if we just return lists.
        // But the requirement says "The catalog must support...".
        // And "Product" model expects specific fields.
        // Let's generate a subset or just store metadata to generate on fly?
        // Actually, the previous CSV approach generated individual products.
        // Here we have a schema.
        // We can generate "Virtual Products" when requested or just populate the lists for the Wizard.
        // But for "Auto Suggest" we need a searchable list.
        // Let's generate a reasonable number of products for search, or implement search differently.
        
        // For the Wizard:
        // 1. Get Categories -> returns `categories` list.
        // 2. Get Subcategories(Category) -> returns `types` list.
        // 3. Get ProductTypes(Subcategory) -> returns empty or same as subcategory?
        //    Let's map Subcategory -> [Subcategory] (Identity) so step 3 is trivial.
        // 4. Get Brands -> returns `catBrands`.
        // 5. Get Variants -> returns `sizes` (The UI treats variants as sizes).
        
        for (var type in types) {
           productTypes[type] = [type]; // 1-to-1 mapping for now
           
           // Generate some sample products for Auto-Suggest (e.g. first brand, first size)
           // or if we want full search, we might need to be smart.
           // Generating ALL combinations: 30 types * 30 brands * 10 variants * 10 sizes = 90,000 per category. Too many.
           // We will NOT generate all. We will use the metadata for the Wizard.
           // For Auto-Suggest, we can search against the metadata (Brand + Type).
        }
      }
      
      brands = allBrands.toList()..sort();
      _isLoaded = true;
    } catch (e) {
      debugPrint("Error loading catalog: $e");
    }
  }

  // API Methods

  Future<List<String>> getCategories() async {
    await _ensureLoaded();
    return categories;
  }

  Future<List<String>> getSubcategories(String category) async {
    await _ensureLoaded();
    return subcategories[category] ?? [];
  }

  Future<List<String>> getProductTypes(String subcategory) async {
    await _ensureLoaded();
    // In this JSON schema, "types" are essentially the subcategories.
    // We can return a generic list or the subcategory itself if we want to skip a level.
    // Let's return the subcategory name as the single "Type" to keep the flow consistent.
    return [subcategory];
  }

  Future<List<String>> getBrands() async {
    await _ensureLoaded();
    return brands;
  }
  
  // Helper to get brands for a specific category (since JSON groups brands by category)
  Future<List<String>> getBrandsForCategory(String category) async {
    await _ensureLoaded();
    // We need to find the category object again or cache it.
    // For efficiency, let's just return all brands or re-parse/cache better.
    // Given the structure, brands are per category.
    // Let's improve _ensureLoaded to store brands per category.
    // For now, I'll iterate.
    try {
      final jsonString = await rootBundle.loadString('assets/data/consolidated_products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoryList = jsonData['categories'];
      final catData = categoryList.firstWhere((c) => c['name'] == category, orElse: () => null);
      if (catData != null) {
        return List<String>.from(catData['brands'] ?? []);
      }
    } catch (e) {
      debugPrint('$e');
    }
    return brands; // Fallback
  }

  Future<List<Product>> getProductsByBrandAndType(String brand, String productType) async {
    await _ensureLoaded();
    // This is called in Step 4 (Variant Selection).
    // We need to return "Products" that represent the available sizes/variants.
    // In the JSON, sizes/variants are stored in the category.
    // We need to find which category this productType belongs to.
    // This is a reverse lookup or we pass category context.
    // The Provider has `selectedCategory`. But here we only have arguments.
    // We can try to find the category that contains this productType.
    
    List<String> sizes = [];
    String categoryName = '';
    
    // Find category for this type
    try {
      final jsonString = await rootBundle.loadString('assets/data/consolidated_products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoryList = jsonData['categories'];
      
      for (var cat in categoryList) {
        final types = List<String>.from(cat['types'] ?? []);
        if (types.contains(productType)) {
          sizes = List<String>.from(cat['sizes'] ?? []);
          categoryName = cat['name'];
          break;
        }
      }
    } catch (e) {
      debugPrint('$e');
    }
    
    // Create Mock Products for each size to fit the UI
    return sizes.map((size) {
      final sizeData = SizeParser.parse(size);
      final canonicalName = '$brand $productType $size';
      return Product(
        id: '${brand}_${productType}_$size',
        category: categoryName,
        subcategory: productType,
        productType: productType,
        brand: brand,
        variant: 'Standard', // Default
        canonicalSize: sizeData['canonical'],
        sizeValue: sizeData['value'],
        sizeUnit: sizeData['unit'],
        canonicalName: canonicalName,
        tags: [categoryName, productType, brand],
        imageUrl: _getImage(canonicalName),
      );
    }).toList();
  }

  String _getImage(String query) {
    return 'https://tse2.mm.bing.net/th?q=${Uri.encodeComponent(query)}&w=300&h=300&c=7&rs=1&p=0';
  }
  
  Future<List<Product>> searchCatalog(String query) async {
    await _ensureLoaded();
    // Search is tricky without full expansion.
    // We can search Categories, Types, and Brands.
    // If query matches a Brand "Britannia", we can suggest "Britannia Biscuits", "Britannia Bread".
    // If query matches "Milk", we suggest "Milk Biscuits", "Milk Bread".
    
    final q = query.toLowerCase();
    List<Product> results = [];
    
    // Simple search implementation:
    // Iterate categories -> types -> brands
    // If match, generate a representative product.
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/consolidated_products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoryList = jsonData['categories'];
      
      for (var cat in categoryList) {
        final catName = cat['name'].toString();
        final types = List<String>.from(cat['types'] ?? []);
        final catBrands = List<String>.from(cat['brands'] ?? []);
        
        // Check if query matches Category, Type or Brand
        bool catMatch = catName.toLowerCase().contains(q);
        
        for (var type in types) {
          bool typeMatch = type.toLowerCase().contains(q);
          
          if (catMatch || typeMatch) {
             // Add a generic item
             results.add(Product(
               id: 'search_$type',
               category: catName,
               subcategory: type,
               productType: type,
               brand: catBrands.isNotEmpty ? catBrands.first : 'Generic',
               variant: 'Standard',
               canonicalSize: 'N/A',
               sizeValue: 0,
               sizeUnit: '',
               canonicalName: '$type ($catName)',
               tags: [catName, type],
               imageUrl: _getImage('$type $catName'),
             ));
          }
        }
        
        // Brand search
        for (var brand in catBrands) {
          if (brand.toLowerCase().contains(q)) {
             // Add a few types for this brand
             for (var type in types.take(3)) {
               results.add(Product(
                 id: 'search_${brand}_$type',
                 category: catName,
                 subcategory: type,
                 productType: type,
                 brand: brand,
                 variant: 'Standard',
                 canonicalSize: 'N/A',
                 sizeValue: 0,
                 sizeUnit: '',
                 canonicalName: '$brand $type',
                 tags: [catName, type, brand],
                 imageUrl: _getImage('$brand $type'),
               ));
             }
          }
        }
      }
    } catch (e) {
      debugPrint('$e');
    }
    
    return results.take(20).toList();
  }

  Future<void> addShopProduct(ShopProduct shopProduct, {Product? productDetails}) async {
    // Determine details
    String name = shopProduct.productId;
    String brand = 'Unknown';
    String category = 'Unknown';
    String variant = 'Standard';
    String imageUrl = '';
    
    if (productDetails != null) {
      name = productDetails.canonicalName;
      brand = productDetails.brand;
      category = productDetails.category;
      variant = productDetails.canonicalSize;
      imageUrl = productDetails.imageUrl;
    } else {
      // Fallback
      final parts = shopProduct.productId.split('_');
      if (parts.length >= 3) {
         brand = parts[0];
         final type = parts[1];
         variant = parts.sublist(2).join(' ');
         name = '$brand $type $variant';
      }
      imageUrl = _getImage(name);
    }

    final inventoryItem = InventoryItem(
      productId: shopProduct.productId,
      productName: name,
      brand: brand,
      category: category,
      variant: variant,
      price: shopProduct.price ?? 0.0,
      stockQty: 10,
      imageUrl: imageUrl,
      source: 'catalog',
      status: 'approved',
    );

    // Write to Firestore
    try {
      await FirebaseService().addToInventory(shopProduct.shopId, inventoryItem.toMap());
    } catch (e) {
      debugPrint('Error adding to firestore inventory: $e');
    }
  }

  Future<void> addCustomProduct(CustomProductCandidate candidate) async {
    final inventoryItem = InventoryItem(
      productId: candidate.id,
      productName: candidate.name,
      brand: candidate.brand ?? 'Generic',
      category: candidate.category ?? 'General',
      variant: candidate.size ?? 'Standard',
      price: candidate.price ?? 0.0,
      stockQty: 10, // Default stock
      imageUrl: candidate.imageUrl ?? '',
      source: 'custom',
      status: 'pending',
    );

    try {
      await FirebaseService().addToInventory(candidate.shopId, inventoryItem.toMap());
    } catch (e) {
      debugPrint('Error adding custom product to firestore: $e');
    }
  }
  
  Future<List<Product>> autoSuggest(String name, String? barcode) async {
    // Reuse search logic
    return searchCatalog(name);
  }
}
