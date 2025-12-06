/// Shop Model for Firestore
class ShopData {
  final String? id;
  final String shopName;
  final String ownerName;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final bool isOpen;
  final double rating;
  final String category;
  final OpeningHours? openingHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> initialProductIds;

  ShopData({
    this.id,
    required this.shopName,
    required this.ownerName,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.isOpen = true,
    this.rating = 5.0,
    this.category = 'Grocery',
    this.openingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.initialProductIds = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
      'rating': rating,
      'category': category,
      'openingHours': openingHours?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'initialProductIds': initialProductIds,
    };
  }

  factory ShopData.fromMap(Map<String, dynamic> map, {String? id}) {
    return ShopData(
      id: id ?? map['id'],
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      isOpen: map['isOpen'] ?? true,
      rating: (map['rating'] ?? 5.0).toDouble(),
      category: map['category'] ?? 'Grocery',
      openingHours: map['openingHours'] != null 
          ? OpeningHours.fromMap(map['openingHours']) 
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
      initialProductIds: List<String>.from(map['initialProductIds'] ?? []),
    );
  }

  ShopData copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool? isOpen,
    double? rating,
    String? category,
    OpeningHours? openingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? initialProductIds,
  }) {
    return ShopData(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      openingHours: openingHours ?? this.openingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      initialProductIds: initialProductIds ?? this.initialProductIds,
    );
  }
}

/// Opening Hours Model
class OpeningHours {
  final Map<String, DayHours> schedule;

  OpeningHours({required this.schedule});

  factory OpeningHours.defaultHours() {
    final defaultDay = DayHours(
      isOpen: true,
      openTime: '09:00',
      closeTime: '21:00',
    );
    return OpeningHours(schedule: {
      'monday': defaultDay,
      'tuesday': defaultDay,
      'wednesday': defaultDay,
      'thursday': defaultDay,
      'friday': defaultDay,
      'saturday': defaultDay,
      'sunday': DayHours(isOpen: false, openTime: '09:00', closeTime: '21:00'),
    });
  }

  Map<String, dynamic> toMap() {
    return schedule.map((key, value) => MapEntry(key, value.toMap()));
  }

  factory OpeningHours.fromMap(Map<String, dynamic> map) {
    return OpeningHours(
      schedule: map.map((key, value) => MapEntry(key, DayHours.fromMap(value))),
    );
  }
}

class DayHours {
  final bool isOpen;
  final String openTime;
  final String closeTime;

  DayHours({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  factory DayHours.fromMap(Map<String, dynamic> map) {
    return DayHours(
      isOpen: map['isOpen'] ?? false,
      openTime: map['openTime'] ?? '09:00',
      closeTime: map['closeTime'] ?? '21:00',
    );
  }
}

/// Inventory Item Model
class InventoryItem {
  final String? id;
  final String productId;
  final String productName;
  final String brand;
  final String category;
  final String variant;
  final double price;
  final double? costPrice;
  final int stockQty;
  final int lowStockThreshold;
  final String imageUrl;
  final String source; // 'catalog' or 'custom'
  final String status; // 'approved', 'pending'
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.brand,
    required this.category,
    required this.variant,
    required this.price,
    this.costPrice,
    required this.stockQty,
    this.lowStockThreshold = 10,
    required this.imageUrl,
    this.source = 'catalog',
    this.status = 'approved',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isLowStock => stockQty <= lowStockThreshold;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'brand': brand,
      'category': category,
      'variant': variant,
      'price': price,
      'costPrice': costPrice,
      'stockQty': stockQty,
      'lowStockThreshold': lowStockThreshold,
      'imageUrl': imageUrl,
      'source': source,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return InventoryItem(
      id: id ?? map['id'],
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      variant: map['variant'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      costPrice: map['costPrice']?.toDouble(),
      stockQty: map['stockQty'] ?? 0,
      lowStockThreshold: map['lowStockThreshold'] ?? 10,
      imageUrl: map['imageUrl'] ?? '',
      source: map['source'] ?? 'catalog',
      status: map['status'] ?? 'approved',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? brand,
    String? category,
    String? variant,
    double? price,
    double? costPrice,
    int? stockQty,
    int? lowStockThreshold,
    String? imageUrl,
    String? source,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      variant: variant ?? this.variant,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
