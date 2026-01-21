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
    address: 'Hotel Kannappa Side Road, Thillai Nagar, Trichy',
    distance: 0.5,
    isOpen: true,
    rating: 4.5,
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    category: 'Grocery',
    phoneNumber: '9600212345',
    password: '1234',
    mapLink: 'https://maps.app.goo.gl/i1fxjMnowzUrdHhi9',
    latitude: 10.7854060,  // Near Hotel Kannappa, Thillai Nagar
    longitude: 78.6890636,
  ),
  ShopModel(
    id: '2',
    name: 'ROYAL Supermarket',
    address: 'No. 33, 3rd Cross Road East, Thillai Nagar, Trichy',
    distance: 1.2,
    isOpen: true,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Supermarket',
    phoneNumber: '9876543210',
    password: '5678',
    mapLink: 'https://maps.app.goo.gl/MJ3WkCxXJVVdAqGb8',
    latitude: 10.825221,   // Thillai Nagar 3rd Cross Road
    longitude: 78.683422,
  ),
  ShopModel(
    id: '3',
    name: 'Reliance SMART Point',
    address: 'No. 100-C, Salai Rd, Woraiyur, Trichy',
    distance: 2.5,
    isOpen: true,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Supermarket',
    phoneNumber: '04312413713',
    password: '0123',
    mapLink: 'https://maps.app.goo.gl/ogicrTG3KCY8muRM6',
    latitude: 10.830512,   // Woraiyur area
    longitude: 78.682419,
  ),
  ShopModel(
    id: '4',
    name: 'J B Super Market',
    address: '78, Madurai Main Road, Melapudur, Trichy',
    distance: 4.0,
    isOpen: true,
    rating: 4.3,
    imageUrl: 'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8',
    category: 'Supermarket',
    phoneNumber: '1234567890',
    password: '9876',
    mapLink: 'https://maps.app.goo.gl/6da5rhMSJcbjCRJY7',
    latitude: 10.80783,    // Melapudur, Madurai Main Road
    longitude: 78.69416,
  ),
  ShopModel(
    id: '5',
    name: 'More Supermarket',
    address: 'No. 5, 80 Feet Road, KK Nagar, Trichy',
    distance: 3.2,
    isOpen: true,
    rating: 4.4,
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    category: 'Supermarket',
    phoneNumber: '9000011111',
    password: '5555',
    mapLink: 'https://maps.app.goo.gl/KKNagarMore',
    latitude: 10.7711,    // KK Nagar
    longitude: 78.7111,
  ),
];
