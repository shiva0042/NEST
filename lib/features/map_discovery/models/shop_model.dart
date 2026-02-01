class ShopModel {
  static const String collectionName = 'shops';

  final String id;
  final String name;
  final String address;
  final double distance;
  final bool isOpen;
  final double rating;
  final String imageUrl;
  final String category;
  final String phoneNumber; // Login ID
  final String password;    // Passkey
  final String? mapLink;    // Google Maps link
  final double latitude;    // For map display
  final double longitude;   // For map display

  ShopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.isOpen,
    required this.rating,
    required this.imageUrl,
    required this.category,
    required this.phoneNumber,
    required this.password,
    this.mapLink,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance': distance,
      'isOpen': isOpen,
      'rating': rating,
      'imageUrl': imageUrl,
      'category': category,
      'phoneNumber': phoneNumber,
      'password': password,
      'mapLink': mapLink,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    String shopId = map['id'] ?? '';
    // If coordinates are missing (0.0), try to find them from mock data
    double lat = (map['latitude'] ?? 0.0).toDouble();
    double lng = (map['longitude'] ?? 0.0).toDouble();
    
    if (lat == 0.0 || lat == 10.7905) {
      try {
        final mock = mockShops.firstWhere((s) => s.id == shopId || s.name == map['name']);
        lat = mock.latitude;
        lng = mock.longitude;
      } catch (e) {
        // Fallback to center if not found
        lat = 10.8065;
        lng = 78.6900;
      }
    }

    return ShopModel(
      id: shopId,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
      isOpen: map['isOpen'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      category: map['category'] ?? 'General',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      mapLink: map['mapLink'],
      latitude: lat,
      longitude: lng,
    );
  }
}

// Mock shops with ACCURATE Trichy coordinates from Google Maps
final List<ShopModel> mockShops = [
  ShopModel(
    id: '1',
    name: 'GRO MART',
    address: 'Near Hotel Kannappa, Thillai Nagar, Trichy',
    distance: 0.5,
    isOpen: true,
    rating: 4.5,
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    category: 'Grocery',
    phoneNumber: '9600212345',
    password: '1234',
    mapLink: 'https://www.google.com/maps/search/?api=1&query=10.8282887,78.6834262',
    latitude: 10.8282887,
    longitude: 78.6834262,
  ),
  ShopModel(
    id: '2',
    name: 'ROYAL Supermarket',
    address: '33, 3rd Cross Rd E, Thillai Nagar, Trichy',
    distance: 1.2,
    isOpen: true,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Supermarket',
    phoneNumber: '9876543210',
    password: '5678',
    mapLink: 'https://www.google.com/maps/search/?api=1&query=10.8251862,78.6842118',
    latitude: 10.8251862,
    longitude: 78.6842118,
  ),
  ShopModel(
    id: '3',
    name: 'SRI RANGA Supermarket',
    address: 'Thillai Nagar, Trichy',
    distance: 2.0,
    isOpen: true,
    rating: 4.4,
    imageUrl: 'https://images.unsplash.com/photo-1604719312566-b7cb96634836',
    category: 'Supermarket',
    phoneNumber: '9000011111',
    password: '5555',
    mapLink: 'https://www.google.com/maps/search/?api=1&query=10.8246069,78.6824307',
    latitude: 10.8246069,
    longitude: 78.6824307,
  ),
  ShopModel(
    id: '4',
    name: 'Reliance SMART Point',
    address: 'Salai Rd, Woraiyur, Trichy',
    distance: 2.5,
    isOpen: true,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Supermarket',
    phoneNumber: '04312413713',
    password: '0123',
    mapLink: 'https://www.google.com/maps/search/?api=1&query=10.8085650,78.6852076',
    latitude: 10.8085650,
    longitude: 78.6852076,
  ),
  ShopModel(
    id: '5',
    name: 'J B Super Market',
    address: 'Madurai Main Road, Trichy',
    distance: 4.0,
    isOpen: true,
    rating: 4.3,
    imageUrl: 'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8',
    category: 'Supermarket',
    phoneNumber: '1234567890',
    password: '9876',
    mapLink: 'https://www.google.com/maps/search/?api=1&query=10.8026824,78.6892880',
    latitude: 10.8026824,
    longitude: 78.6892880,
  ),
];
