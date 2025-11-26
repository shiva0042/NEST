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
  });
}

final List<ShopModel> mockShops = [
  ShopModel(
    id: '1',
    name: 'Murugan Stores',
    address: 'Thillai Nagar, Trichy',
    distance: 0.5,
    isOpen: true,
    rating: 4.5,
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    category: 'Grocery',
    phoneNumber: '9876543210',
    password: '1234',
  ),
  ShopModel(
    id: '2',
    name: 'Aagappa Malligai Kadai',
    address: 'Gandhi Market, Trichy',
    distance: 1.2,
    isOpen: true,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Grocery',
    phoneNumber: '9876543211',
    password: '1234',
  ),
  ShopModel(
    id: '3',
    name: 'SRK SF Market',
    address: 'Cantonment, Trichy',
    distance: 2.5,
    isOpen: false,
    rating: 4.6,
    imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
    category: 'Grocery',
    phoneNumber: '9876543212',
    password: '1234',
  ),
  ShopModel(
    id: '4',
    name: 'Krishna Supermarket',
    address: 'Srirangam, Trichy',
    distance: 4.0,
    isOpen: true,
    rating: 4.3,
    imageUrl: 'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8',
    category: 'Grocery',
    phoneNumber: '9876543213',
    password: '1234',
  ),
  ShopModel(
    id: '5',
    name: 'Annai Provision Store',
    address: 'K.K. Nagar, Trichy',
    distance: 3.2,
    isOpen: true,
    rating: 4.1,
    imageUrl: 'https://images.unsplash.com/photo-1534723452862-4c874018d66d',
    category: 'Grocery',
    phoneNumber: '9876543214',
    password: '1234',
  ),
];
