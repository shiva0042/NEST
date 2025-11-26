import 'dart:math';

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool inStock;
  final int stockQuantity;
  final String category;
  final String brand;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.inStock,
    this.stockQuantity = 0,
    required this.category,
    required this.brand,
  });
}

// Helper to generate products
List<ProductModel> _generateProducts() {
  final List<ProductModel> allProducts = [];
  final Random random = Random();

  // Using a CORS proxy to allow loading external images in the web browser if needed
  // Bing thumbnails usually work directly, but we can wrap them if issues arise.
  // String _proxy(String url) => 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
  
  // Dynamic image generator using Bing Thumbnails
  String _getImage(String query) {
    return 'https://tse2.mm.bing.net/th?q=${Uri.encodeComponent(query)}&w=300&h=300&c=7&rs=1&p=0';
  }

  final List<Map<String, dynamic>> baseItems = [
    {
      'name': 'Ponni Rice (5kg)',
      'category': 'Rice & Grains',
      'brands': ['India Gate', 'Daawat', 'Udhaiyam', 'Shivaji'],
      'basePrice': 350.0,
    },
    {
      'name': 'Sunflower Oil (1L)',
      'category': 'Oil & Masala',
      'brands': ['Gold Winner', 'Fortune', 'Sunland', 'Freedom'],
      'basePrice': 140.0,
    },
    {
      'name': 'Toor Dal (1kg)',
      'category': 'Dals & Pulses',
      'brands': ['Udhaiyam', 'Tata Sampann', 'Loose Premium', 'Aagappa'],
      'basePrice': 160.0,
    },
    {
      'name': 'Wheat Flour Atta (5kg)',
      'category': 'Flours',
      'brands': ['Aashirvaad', 'Pillsbury', 'Naga', 'Annapurna'],
      'basePrice': 280.0,
    },
    {
      'name': 'Sugar (1kg)',
      'category': 'Salt & Sugar',
      'brands': ["Parry's", 'Madhur', 'Trust'],
      'basePrice': 45.0,
    },
    {
      'name': 'Salt (1kg)',
      'category': 'Salt & Sugar',
      'brands': ['Tata Salt', 'Aashirvaad', 'Annapurna'],
      'basePrice': 25.0,
    },
    {
      'name': 'Tea Powder (250g)',
      'category': 'Beverages',
      'brands': ['3 Roses', 'Red Label', 'Taj Mahal', 'Chakra Gold'],
      'basePrice': 180.0,
    },
    {
      'name': 'Coffee Powder (50g)',
      'category': 'Beverages',
      'brands': ['Bru', 'Sunrise', 'Nescafe', 'Narasus'],
      'basePrice': 90.0,
    },
    {
      'name': 'Milk (500ml)',
      'category': 'Dairy',
      'brands': ['Aavin', 'Arokyam', 'Tirumala', 'Heritage'],
      'basePrice': 24.0,
    },
    {
      'name': 'Curd (500g)',
      'category': 'Dairy',
      'brands': ['Aavin', 'Milky Mist', 'Hatsun', 'Cavins'],
      'basePrice': 35.0,
    },
    {
      'name': 'Butter (200g)',
      'category': 'Dairy',
      'brands': ['Amul', 'Milky Mist', 'Aavin'],
      'basePrice': 120.0,
    },
    {
      'name': 'Biscuits (Pack)',
      'category': 'Snacks',
      'brands': ['Britannia Marie', 'Parle-G', 'Sunfeast Mom\'s Magic', 'Good Day'],
      'basePrice': 30.0,
    },
    {
      'name': 'Instant Noodles (Pack)',
      'category': 'Instant Food',
      'brands': ['Maggi', 'Yippee', 'Top Ramen'],
      'basePrice': 14.0,
    },
    {
      'name': 'Washing Powder (1kg)',
      'category': 'Household',
      'brands': ['Surf Excel', 'Ariel', 'Rin', 'Tide'],
      'basePrice': 150.0,
    },
    {
      'name': 'Dish Wash Bar',
      'category': 'Household',
      'brands': ['Vim', 'Exo', 'Pril'],
      'basePrice': 20.0,
    },
    {
      'name': 'Tomato (1kg)',
      'category': 'Vegetables',
      'brands': ['Fresh', 'Organic'],
      'basePrice': 40.0,
    },
    {
      'name': 'Onion (1kg)',
      'category': 'Vegetables',
      'brands': ['Fresh', 'Organic'],
      'basePrice': 30.0,
    },
    {
      'name': 'Potato (1kg)',
      'category': 'Vegetables',
      'brands': ['Fresh', 'Organic'],
      'basePrice': 35.0,
    },
    // Fruits
    {
      'name': 'Apple (1kg)',
      'category': 'Fruits',
      'brands': ['Washington', 'Fuji', 'Shimla', 'Green'],
      'basePrice': 180.0,
    },
    {
      'name': 'Banana (1kg)',
      'category': 'Fruits',
      'brands': ['Robusta', 'Yelakki', 'Nendran'],
      'basePrice': 40.0,
    },
    {
      'name': 'Orange (1kg)',
      'category': 'Fruits',
      'brands': ['Nagpur', 'Imported', 'Kinnow'],
      'basePrice': 80.0,
    },
    // Eggs
    {
      'name': 'Eggs (6pcs)',
      'category': 'Eggs',
      'brands': ['Farm Fresh', 'Suguna', 'Organic'],
      'basePrice': 45.0,
    },
    {
      'name': 'Brown Eggs (6pcs)',
      'category': 'Eggs',
      'brands': ['Farm Fresh', 'Organic'],
      'basePrice': 60.0,
    },
    // Bakery
    {
      'name': 'Bread (400g)',
      'category': 'Bakery',
      'brands': ['Modern', 'Britannia', 'Elite', 'Local'],
      'basePrice': 40.0,
    },
    {
      'name': 'Bun (Pack of 4)',
      'category': 'Bakery',
      'brands': ['Modern', 'Britannia', 'Local'],
      'basePrice': 20.0,
    },
    // Munchies
    {
      'name': 'Potato Chips (Pack)',
      'category': 'Munchies',
      'brands': ['Lays', 'Bingo', 'Pringles', 'Haldirams'],
      'basePrice': 20.0,
    },
    {
      'name': 'Chocolate Bar',
      'category': 'Munchies',
      'brands': ['Cadbury Dairy Milk', 'Nestle KitKat', 'Snickers', 'Munch'],
      'basePrice': 40.0,
    },
    // Cold Drinks
    {
      'name': 'Soft Drink (750ml)',
      'category': 'Cold Drinks',
      'brands': ['Coca Cola', 'Pepsi', 'Sprite', 'Thums Up'],
      'basePrice': 45.0,
    },
    {
      'name': 'Fruit Juice (1L)',
      'category': 'Cold Drinks',
      'brands': ['Real', 'Tropicana', 'B Natural'],
      'basePrice': 110.0,
    },
  ];

  // Generate for each shop
  for (int shopId = 1; shopId <= 5; shopId++) {
    int productIdCounter = 1;
    
    for (var item in baseItems) {
      List<String> brands = item['brands'];
      double basePrice = item['basePrice'];
      
      // Add each brand as a separate product
      for (var brand in brands) {
        // Randomize price slightly per shop/brand
        double price = basePrice + random.nextInt(20) - 10;
        if (price < 10) price = 10;
        
        // Random stock status
        bool inStock = random.nextDouble() > 0.1; // 90% in stock

        String productName = '$brand ${item['name']}';
        // Generate specific image for this brand+product
        String imageUrl = _getImage(productName);

        allProducts.add(ProductModel(
          id: '${shopId}_${productIdCounter++}',
          shopId: '$shopId',
          name: productName,
          price: price,
          originalPrice: random.nextBool() ? price + random.nextInt(20) + 5 : null,
          imageUrl: imageUrl,
          inStock: inStock,
          stockQuantity: inStock ? random.nextInt(50) + 1 : 0,
          category: item['category'],
          brand: brand,
        ));
      }
    }
  }

  return allProducts;
}

List<ProductModel> mockProducts = _generateProducts();
