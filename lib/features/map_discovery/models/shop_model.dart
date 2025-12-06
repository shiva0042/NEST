class ShopModel {
  final String id;
  final String name;
  final String address;
  final double distance;
  final bool isOpen;
  final double rating;
  final String imageUrl;
  final String category;
  final String phoneNumber; // Login ID
  final String password;    // OTP
  final String? mapLink;    // Google Maps link

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
  });
}

final List<ShopModel> mockShops = [
  ShopModel(
    id: '1',
    name: 'GRO MART',
    address: 'Trichy',
    distance: 0.5,
    isOpen: true,
    rating: 4.5,
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    category: 'Grocery',
    phoneNumber: '9600212345',
    password: '1234',
    mapLink: 'https://maps.app.goo.gl/i1fxjMnowzUrdHhi9',
  ),
  ShopModel(
    id: '2',
    name: 'ROYAL Supermarket',
    address: 'Trichy',
    distance: 1.2,
    isOpen: true,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Supermarket',
    phoneNumber: '9876543210',
    password: '5678',
    mapLink: 'https://maps.app.goo.gl/MJ3WkCxXJVVdAqGb8',
  ),
  ShopModel(
    id: '3',
    name: 'Reliance SMART Point',
    address: 'Trichy',
    distance: 2.5,
    isOpen: true,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Supermarket',
    phoneNumber: '04312413713',
    password: '0123',
    mapLink: 'https://maps.app.goo.gl/ogicrTG3KCY8muRM6',
  ),
  ShopModel(
    id: '4',
    name: 'J B Super Market',
    address: 'Trichy',
    distance: 4.0,
    isOpen: true,
    rating: 4.3,
    imageUrl: 'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8',
    category: 'Supermarket',
    phoneNumber: '1234567890',
    password: '9876',
    mapLink: 'https://maps.app.goo.gl/6da5rhMSJcbjCRJY7',
  ),
];
