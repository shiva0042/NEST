class Product {
  final String id;
  final String category;
  final String subcategory;
  final String productType;
  final String brand;
  final String variant; // Pouch, TetraPack, etc.
  final String? flavour;
  final String canonicalSize; // "500 ml"
  final double sizeValue; // 500
  final String sizeUnit; // ml
  final String? barcode;
  final String? sku;
  final String canonicalName;
  final List<String> tags;
  final String imageUrl;

  Product({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.productType,
    required this.brand,
    required this.variant,
    this.flavour,
    required this.canonicalSize,
    required this.sizeValue,
    required this.sizeUnit,
    this.barcode,
    this.sku,
    required this.canonicalName,
    required this.tags,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: json['category'],
      subcategory: json['subcategory'],
      productType: json['product_type'],
      brand: json['brand'],
      variant: json['variant'],
      flavour: json['flavour'],
      canonicalSize: json['canonical_size'],
      sizeValue: json['size_value'].toDouble(),
      sizeUnit: json['size_unit'],
      barcode: json['barcode'],
      sku: json['sku'],
      canonicalName: json['canonical_name'],
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'product_type': productType,
      'brand': brand,
      'variant': variant,
      'flavour': flavour,
      'canonical_size': canonicalSize,
      'size_value': sizeValue,
      'size_unit': sizeUnit,
      'barcode': barcode,
      'sku': sku,
      'canonical_name': canonicalName,
      'tags': tags,
      'image_url': imageUrl,
    };
  }
}

class ShopProduct {
  final String id;
  final String shopId;
  final String productId; // Reference to Master Product
  final double? price;
  final bool isAvailable;
  final String source; // 'catalog', 'custom'
  final String catalogStatus; // 'approved', 'pending'
  
  // If source is custom, we might store details here or link to a CustomProduct
  // For simplicity, let's assume we link to Product ID which might be a temporary ID for custom items
  // or we embed custom details.
  // The requirement says: "Uploaded custom products go to: immediate local shop_products entry... and a master-catalog candidate queue"
  
  ShopProduct({
    required this.id,
    required this.shopId,
    required this.productId,
    this.price,
    this.isAvailable = true,
    required this.source,
    required this.catalogStatus,
  });
}

class CustomProductCandidate {
  final String id;
  final String shopId;
  final String name;
  final String? brand;
  final String? category;
  final String? variant;
  final String? size;
  final String? flavour;
  final String? barcode;
  final double? price;
  final String? imageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final List<String> tags;

  CustomProductCandidate({
    required this.id,
    required this.shopId,
    required this.name,
    this.brand,
    this.category,
    this.variant,
    this.size,
    this.flavour,
    this.barcode,
    this.price,
    this.imageUrl,
    required this.status,
    required this.tags,
  });
}

// Helper for Size Parsing
class SizeParser {
  static Map<String, dynamic> parse(String input) {
    // Simple regex to separate value and unit
    // 1 L -> 1000 ml
    // 1 kg -> 1000 g
    
    final RegExp regex = RegExp(r'^(\d+(?:\.\d+)?)\s*([a-zA-Z]+)$');
    final match = regex.firstMatch(input.trim());
    
    if (match != null) {
      double value = double.parse(match.group(1)!);
      String unit = match.group(2)!.toLowerCase();
      
      if (unit == 'l' || unit == 'liter' || unit == 'litre') {
        value = value * 1000;
        unit = 'ml';
      } else if (unit == 'kg' || unit == 'kilogram') {
        value = value * 1000;
        unit = 'g';
      }
      
      return {
        'value': value,
        'unit': unit,
        'canonical': '${value.toStringAsFixed(0)} $unit' // simplified
      };
    }
    return {
      'value': 0.0,
      'unit': 'unknown',
      'canonical': input
    };
  }
}
