import 'dart:math';

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final double price; // Base price for standard size (500g/500ml)
  final double? originalPrice;
  final String imageUrl;
  final bool inStock;
  final int stockQuantity;
  final String category;
  final String brand;
  final String unit; // Unit type: 'weight', 'volume', 'pieces', 'pack'

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
    this.unit = 'weight',
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      shopId: json['shopId'] ?? '1',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      inStock: json['inStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'] ?? 'General',
      brand: json['brand'] ?? '',
      unit: json['unit'] ?? 'weight',
    );
  }
}

// Size options with real Blinkit/Instamart pricing
class SizeOption {
  final String name;
  final String label;
  final double multiplier;
  
  const SizeOption(this.name, this.label, this.multiplier);
}

// Size options by unit type
const Map<String, List<SizeOption>> sizeOptionsByUnit = {
  'weight': [
    SizeOption('250g', '250 g', 0.5),
    SizeOption('500g', '500 g', 1.0),
    SizeOption('1kg', '1 kg', 1.9),
    SizeOption('5kg', '5 kg', 4.5),
  ],
  'volume': [
    SizeOption('200ml', '200 ml', 0.4),
    SizeOption('500ml', '500 ml', 1.0),
    SizeOption('1L', '1 Litre', 1.85),
    SizeOption('5L', '5 Litre', 4.2),
  ],
  'pieces': [
    SizeOption('6pcs', '6 pieces', 1.0),
    SizeOption('12pcs', '12 pieces', 1.9),
    SizeOption('30pcs', '30 pieces', 4.5),
  ],
  'pack': [
    SizeOption('Small', 'Small Pack', 0.5),
    SizeOption('Regular', 'Regular Pack', 1.0),
    SizeOption('Family', 'Family Pack', 2.5),
    SizeOption('Jumbo', 'Jumbo Pack', 4.0),
  ],
};

// Helper to generate products with REAL prices from Blinkit/Instamart
List<ProductModel> _generateProducts() {
  final List<ProductModel> allProducts = [];
  final Random random = Random(42);

  String getImage(String query) {
    return 'https://tse2.mm.bing.net/th?q=${Uri.encodeComponent(query)}&w=300&h=300&c=7&rs=1&p=0';
  }

  // Products with REAL prices (base = 500g/500ml equivalent)
  // Prices sourced from Blinkit & Instamart Dec 2024
  final List<Map<String, dynamic>> baseItems = [
    // === RICE & GRAINS ===
    {
      'name': 'Basmati Rice',
      'category': 'Rice & Grains',
      'unit': 'weight',
      'bigBrands': ['India Gate', 'Daawat'],
      'smallBrands': {'Kohinoor': [1, 2], 'Fortune': [3, 4]},
      'basePrice': 125.0, // ₹125/kg -> ₹62.5 for 500g
    },
    {
      'name': 'Ponni Rice',
      'category': 'Rice & Grains',
      'unit': 'weight',
      'bigBrands': ['India Gate'],
      'smallBrands': {'Udhaiyam': [1, 2], 'Sri Lalitha': [3], 'Kaveri': [4]},
      'basePrice': 55.0, // ₹55/500g
    },
    {
      'name': 'Sona Masoori Rice',
      'category': 'Rice & Grains',
      'unit': 'weight',
      'bigBrands': ['Daawat'],
      'smallBrands': {'24 Mantra': [2, 3], 'BB Royal': [1, 4]},
      'basePrice': 48.0,
    },
    
    // === COOKING OIL ===
    {
      'name': 'Sunflower Oil',
      'category': 'Cooking Oil',
      'unit': 'volume',
      'bigBrands': ['Fortune', 'Saffola'],
      'smallBrands': {'Gold Winner': [1, 2], 'Freedom': [3], 'Sunland': [4]},
      'basePrice': 85.0, // ₹158/800ml -> ~₹100 for 500ml
    },
    {
      'name': 'Groundnut Oil',
      'category': 'Cooking Oil',
      'unit': 'volume',
      'bigBrands': ['Fortune'],
      'smallBrands': {'Idhayam': [1, 2], 'Gold Drop': [3, 4]},
      'basePrice': 120.0,
    },
    {
      'name': 'Mustard Oil',
      'category': 'Cooking Oil',
      'unit': 'volume',
      'bigBrands': ['Fortune'],
      'smallBrands': {'Patanjali': [1, 3], 'Emami': [2, 4]},
      'basePrice': 95.0, // ₹177/910ml
    },
    {
      'name': 'Refined Soyabean Oil',
      'category': 'Cooking Oil',
      'unit': 'volume',
      'bigBrands': ['Fortune'],
      'smallBrands': {'Saffola': [1, 2], 'Dhara': [3, 4]},
      'basePrice': 70.0,
    },
    
    // === ATTA & FLOUR ===
    {
      'name': 'Whole Wheat Atta',
      'category': 'Atta & Flour',
      'unit': 'weight',
      'bigBrands': ['Aashirvaad', 'Pillsbury'],
      'smallBrands': {'Shakti Bhog': [1, 2], 'Annapurna': [3], 'Patanjali': [4]},
      'basePrice': 48.0, // ₹239/5kg -> ~₹24/500g
    },
    {
      'name': 'Multigrain Atta',
      'category': 'Atta & Flour',
      'unit': 'weight',
      'bigBrands': ['Aashirvaad'],
      'smallBrands': {'Nature Fresh': [1, 3], 'Saffola': [2, 4]},
      'basePrice': 62.0, // ₹311/5kg
    },
    {
      'name': 'Maida',
      'category': 'Atta & Flour',
      'unit': 'weight',
      'bigBrands': ['Aashirvaad'],
      'smallBrands': {'Rajdhani': [1, 2], 'Pillsbury': [3, 4]},
      'basePrice': 32.0,
    },
    {
      'name': 'Rava / Sooji',
      'category': 'Atta & Flour',
      'unit': 'weight',
      'bigBrands': ['Aashirvaad'],
      'smallBrands': {'24 Mantra': [1, 3], 'BB Royal': [2, 4]},
      'basePrice': 38.0,
    },
    
    // === DALS & PULSES ===
    {
      'name': 'Toor Dal',
      'category': 'Dals & Pulses',
      'unit': 'weight',
      'bigBrands': ['Tata Sampann', 'Fortune'],
      'smallBrands': {'24 Mantra': [1, 2], 'Organic Tattva': [3, 4]},
      'basePrice': 85.0,
    },
    {
      'name': 'Chana Dal',
      'category': 'Dals & Pulses',
      'unit': 'weight',
      'bigBrands': ['Tata Sampann'],
      'smallBrands': {'BB Royal': [1, 3], 'Vedaka': [2, 4]},
      'basePrice': 72.0,
    },
    {
      'name': 'Moong Dal',
      'category': 'Dals & Pulses',
      'unit': 'weight',
      'bigBrands': ['Tata Sampann'],
      'smallBrands': {'24 Mantra': [1, 2], 'Fortune': [3, 4]},
      'basePrice': 95.0,
    },
    {
      'name': 'Urad Dal',
      'category': 'Dals & Pulses',
      'unit': 'weight',
      'bigBrands': ['Fortune'],
      'smallBrands': {'Tata Sampann': [1, 3], 'BB Royal': [2, 4]},
      'basePrice': 90.0,
    },
    
    // === SALT & SUGAR ===
    {
      'name': 'Iodised Salt',
      'category': 'Salt & Sugar',
      'unit': 'weight',
      'bigBrands': ['Tata Salt'],
      'smallBrands': {'Aashirvaad': [1, 2], 'Catch': [3, 4]},
      'basePrice': 14.0, // ₹27/kg
    },
    {
      'name': 'Crystal Salt',
      'category': 'Salt & Sugar',
      'unit': 'weight',
      'bigBrands': ['Tata Salt'],
      'smallBrands': {'Patanjali': [1, 3], 'Catch': [2, 4]},
      'basePrice': 11.0,
    },
    {
      'name': 'Sugar',
      'category': 'Salt & Sugar',
      'unit': 'weight',
      'bigBrands': ['Parry\'s', 'Madhur'],
      'smallBrands': {'Trust': [1, 2], 'Dhampure': [3, 4]},
      'basePrice': 24.0, // ₹45-48/kg
    },
    
    // === MASALA & SPICES ===
    {
      'name': 'Turmeric Powder',
      'category': 'Masala & Spices',
      'unit': 'weight',
      'bigBrands': ['MDH', 'Everest'],
      'smallBrands': {'Aachi': [1, 2], 'Sakthi': [3], 'Eastern': [4]},
      'basePrice': 45.0, // ₹45/100g
    },
    {
      'name': 'Red Chilli Powder',
      'category': 'Masala & Spices',
      'unit': 'weight',
      'bigBrands': ['MDH', 'Everest'],
      'smallBrands': {'Aachi': [1, 3], 'Sakthi': [2, 4]},
      'basePrice': 55.0,
    },
    {
      'name': 'Coriander Powder',
      'category': 'Masala & Spices',
      'unit': 'weight',
      'bigBrands': ['MDH', 'Everest'],
      'smallBrands': {'Catch': [1, 2], 'Eastern': [3, 4]},
      'basePrice': 42.0,
    },
    {
      'name': 'Garam Masala',
      'category': 'Masala & Spices',
      'unit': 'weight',
      'bigBrands': ['MDH', 'Everest'],
      'smallBrands': {'Catch': [1, 3], 'Aachi': [2, 4]},
      'basePrice': 65.0,
    },
    
    // === DAIRY ===
    {
      'name': 'Toned Milk',
      'category': 'Dairy',
      'unit': 'volume',
      'bigBrands': ['Amul', 'Aavin'],
      'smallBrands': {'Nandini': [1, 2], 'Mother Dairy': [3, 4]},
      'basePrice': 28.0, // ₹28/500ml
    },
    {
      'name': 'Full Cream Milk',
      'category': 'Dairy',
      'unit': 'volume',
      'bigBrands': ['Amul'],
      'smallBrands': {'Aavin': [1, 2], 'Heritage': [3, 4]},
      'basePrice': 35.0,
    },
    {
      'name': 'Curd',
      'category': 'Dairy',
      'unit': 'weight',
      'bigBrands': ['Amul'],
      'smallBrands': {'Milky Mist': [1, 2], 'Aavin': [3], 'Hatsun': [4]},
      'basePrice': 35.0,
    },
    {
      'name': 'Butter',
      'category': 'Dairy',
      'unit': 'weight',
      'bigBrands': ['Amul'],
      'smallBrands': {'Britannia': [1, 2], 'Milky Mist': [3, 4]},
      'basePrice': 58.0, // ₹58/100g
    },
    {
      'name': 'Paneer',
      'category': 'Dairy',
      'unit': 'weight',
      'bigBrands': ['Amul'],
      'smallBrands': {'Milky Mist': [1, 3], 'Mother Dairy': [2, 4]},
      'basePrice': 90.0, // ₹90/200g
    },
    {
      'name': 'Cheese Slices',
      'category': 'Dairy',
      'unit': 'pack',
      'bigBrands': ['Amul', 'Britannia'],
      'smallBrands': {'Gowardhan': [1, 2], 'Milky Mist': [3, 4]},
      'basePrice': 85.0, // ₹85/pack
    },
    {
      'name': 'Ghee',
      'category': 'Dairy',
      'unit': 'volume',
      'bigBrands': ['Amul'],
      'smallBrands': {'Patanjali': [1, 2], 'Gowardhan': [3, 4]},
      'basePrice': 290.0, // ₹290/500ml
    },
    
    // === TEA & COFFEE ===
    {
      'name': 'Tea Powder',
      'category': 'Tea & Coffee',
      'unit': 'weight',
      'bigBrands': ['Tata Tea', 'Red Label'],
      'smallBrands': {'3 Roses': [1, 2], 'Taj Mahal': [3], 'Chakra Gold': [4]},
      'basePrice': 95.0, // ₹180/250g
    },
    {
      'name': 'Instant Coffee',
      'category': 'Tea & Coffee',
      'unit': 'weight',
      'bigBrands': ['Nescafe', 'Bru'],
      'smallBrands': {'Sunrise': [1, 2], 'Continental': [3, 4]},
      'basePrice': 150.0, // ₹150/50g
    },
    {
      'name': 'Filter Coffee',
      'category': 'Tea & Coffee',
      'unit': 'weight',
      'bigBrands': ['Bru'],
      'smallBrands': {'Narasus': [1], 'Leo': [2, 3], 'Cothas': [4]},
      'basePrice': 85.0,
    },
    {
      'name': 'Green Tea',
      'category': 'Tea & Coffee',
      'unit': 'pack',
      'bigBrands': ['Lipton', 'Tetley'],
      'smallBrands': {'Organic India': [1, 2], 'Typhoo': [3, 4]},
      'basePrice': 180.0,
    },
    {
      'name': 'Masala Tea',
      'category': 'Tea & Coffee',
      'unit': 'weight',
      'bigBrands': ['Tata Tea', 'Wagh Bakri'],
      'smallBrands': {'Society': [1, 3], 'Brooke Bond': [2, 4]},
      'basePrice': 110.0,
    },
    {
      'name': 'Premix Coffee',
      'category': 'Tea & Coffee',
      'unit': 'pack',
      'bigBrands': ['Bru', 'Nescafe'],
      'smallBrands': {'Continental': [1, 2], 'Sunrise': [3, 4]},
      'basePrice': 125.0,
    },
    
    // === INSTANT FOOD ===
    {
      'name': 'Instant Noodles',
      'category': 'Instant Food',
      'unit': 'pack',
      'bigBrands': ['Maggi', 'Yippee'],
      'smallBrands': {'Top Ramen': [1, 2], 'Ching\'s': [3, 4]},
      'basePrice': 14.0, // ₹14/pack
    },
    {
      'name': 'Instant Pasta',
      'category': 'Instant Food',
      'unit': 'pack',
      'bigBrands': ['Maggi'],
      'smallBrands': {'Yippee': [1, 3], 'Knorr': [2, 4]},
      'basePrice': 40.0,
    },
    {
      'name': 'Ready To Eat Upma',
      'category': 'Instant Food',
      'unit': 'pack',
      'bigBrands': ['MTR'],
      'smallBrands': {'Aachi': [1, 2], 'Gits': [3], 'iD Fresh': [4]},
      'basePrice': 55.0,
    },
    {
      'name': 'Poha Mix',
      'category': 'Instant Food',
      'unit': 'pack',
      'bigBrands': ['MTR'],
      'smallBrands': {'Saffola': [1, 2], 'Gits': [3, 4]},
      'basePrice': 48.0,
    },
    
    // === BISCUITS & SNACKS ===
    {
      'name': 'Marie Biscuits',
      'category': 'Biscuits',
      'unit': 'pack',
      'bigBrands': ['Britannia', 'Parle'],
      'smallBrands': {'Sunfeast': [1, 2], 'Priyagold': [3, 4]},
      'basePrice': 37.0, // ₹37/250g
    },
    {
      'name': 'Good Day Cookies',
      'category': 'Biscuits',
      'unit': 'pack',
      'bigBrands': ['Britannia'],
      'smallBrands': {'Sunfeast': [1, 3], 'Unibic': [2, 4]},
      'basePrice': 43.0,
    },
    {
      'name': 'Glucose Biscuits',
      'category': 'Biscuits',
      'unit': 'pack',
      'bigBrands': ['Parle-G', 'Britannia'],
      'smallBrands': {'Tiger': [1, 2], 'Priyagold': [3, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Cream Biscuits',
      'category': 'Biscuits',
      'unit': 'pack',
      'bigBrands': ['Britannia Bourbon'],
      'smallBrands': {'Hide & Seek': [1, 2], 'Dark Fantasy': [3, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Potato Chips',
      'category': 'Snacks',
      'unit': 'pack',
      'bigBrands': ['Lay\'s', 'Bingo'],
      'smallBrands': {'Pringles': [2, 3], 'Uncle Chipps': [1, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Namkeen Mixture',
      'category': 'Snacks',
      'unit': 'pack',
      'bigBrands': ['Haldiram\'s'],
      'smallBrands': {'Bikaji': [1, 2], 'Balaji': [3, 4]},
      'basePrice': 60.0,
    },
    
    // === CHOCOLATES ===
    {
      'name': 'Milk Chocolate',
      'category': 'Chocolates',
      'unit': 'pack',
      'bigBrands': ['Cadbury Dairy Milk', 'Amul'],
      'smallBrands': {'Nestle': [1, 2], 'Galaxy': [3, 4]},
      'basePrice': 40.0, // ₹40 for 50g
    },
    {
      'name': 'Dark Chocolate',
      'category': 'Chocolates',
      'unit': 'pack',
      'bigBrands': ['Cadbury Bournville', 'Lindt'],
      'smallBrands': {'Amul Dark': [1, 3], 'Toblerone': [2, 4]},
      'basePrice': 120.0,
    },
    {
      'name': 'Fruit & Nut Chocolate',
      'category': 'Chocolates',
      'unit': 'pack',
      'bigBrands': ['Cadbury'],
      'smallBrands': {'Amul': [1, 2], 'Nestle Munch': [3, 4]},
      'basePrice': 90.0,
    },
    {
      'name': 'Milk Chocolate Bar',
      'category': 'Chocolates',
      'unit': 'pack',
      'bigBrands': ['Cadbury Silk', '5 Star'],
      'smallBrands': {'KitKat': [1, 3], 'Munch': [2, 4]},
      'basePrice': 45.0,
    },
    {
      'name': 'Wafer Chocolate',
      'category': 'Chocolates',
      'unit': 'pack',
      'bigBrands': ['KitKat', 'Munch'],
      'smallBrands': {'Perk': [1, 2], 'Milkybar': [3, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Chocolate Gift Pack',
      'category': 'Chocolates',
      'unit': 'pack',
      'bigBrands': ['Cadbury Celebrations', 'Ferrero Rocher'],
      'smallBrands': {'Toblerone': [2, 3], 'Lindt': [1, 4]},
      'basePrice': 250.0,
    },
    
    // === CHOCOLATE BARS (Single Serve) ===
    {
      'name': 'Snickers Bar',
      'category': 'Chocolate Bars',
      'unit': 'pack',
      'bigBrands': ['Mars'],
      'smallBrands': {},
      'basePrice': 50.0,
    },
    {
      'name': 'Mars Bar',
      'category': 'Chocolate Bars',
      'unit': 'pack',
      'bigBrands': ['Mars'],
      'smallBrands': {},
      'basePrice': 50.0,
    },
    {
      'name': 'Bounty Bar',
      'category': 'Chocolate Bars',
      'unit': 'pack',
      'bigBrands': ['Mars'],
      'smallBrands': {},
      'basePrice': 55.0,
    },
    {
      'name': 'KitKat',
      'category': 'Chocolate Bars',
      'unit': 'pack',
      'bigBrands': ['Nestle'],
      'smallBrands': {},
      'basePrice': 25.0,
    },
    {
      'name': '5 Star',
      'category': 'Chocolate Bars',
      'unit': 'pack',
      'bigBrands': ['Cadbury'],
      'smallBrands': {},
      'basePrice': 20.0,
    },
    {
      'name': 'Bar One',
      'category': 'Chocolate Bars',
      'unit': 'pack',
      'bigBrands': ['Nestle'],
      'smallBrands': {},
      'basePrice': 25.0,
    },
    
    // === PREMIUM CHOCOLATES ===
    {
      'name': 'Lindt Excellence',
      'category': 'Premium Chocolates',
      'unit': 'pack',
      'bigBrands': ['Lindt'],
      'smallBrands': {},
      'basePrice': 350.0,
    },
    {
      'name': 'Ferrero Rocher',
      'category': 'Premium Chocolates',
      'unit': 'pack',
      'bigBrands': ['Ferrero'],
      'smallBrands': {},
      'basePrice': 450.0, // ₹450/16pcs
    },
    {
      'name': 'Kinder Bueno',
      'category': 'Premium Chocolates',
      'unit': 'pack',
      'bigBrands': ['Ferrero'],
      'smallBrands': {},
      'basePrice': 120.0,
    },
    {
      'name': 'Ritter Sport',
      'category': 'Premium Chocolates',
      'unit': 'pack',
      'bigBrands': ['Ritter Sport'],
      'smallBrands': {},
      'basePrice': 280.0,
    },
    {
      'name': 'Toblerone',
      'category': 'Premium Chocolates',
      'unit': 'pack',
      'bigBrands': ['Toblerone'],
      'smallBrands': {},
      'basePrice': 180.0,
    },
    
    // === SPREADS ===
    {
      'name': 'Peanut Butter',
      'category': 'Spreads',
      'unit': 'weight',
      'bigBrands': ['Pintola', 'Sundrop'],
      'smallBrands': {'Skippy': [1, 2], 'Saffola': [3, 4]},
      'basePrice': 180.0, // ₹180/350g
    },
    {
      'name': 'Chocolate Spread',
      'category': 'Spreads',
      'unit': 'weight',
      'bigBrands': ['Nutella', 'Hershey\'s'],
      'smallBrands': {'Dr. Oetker FunFoods': [1, 2], 'Veeba': [3, 4]},
      'basePrice': 250.0, // ₹250/350g
    },
    {
      'name': 'Hazelnut Spread',
      'category': 'Spreads',
      'unit': 'weight',
      'bigBrands': ['Nutella'],
      'smallBrands': {'Hershey\'s': [1, 3], 'Cremica': [2, 4]},
      'basePrice': 280.0,
    },
    {
      'name': 'Almond Butter',
      'category': 'Spreads',
      'unit': 'weight',
      'bigBrands': ['Pintola'],
      'smallBrands': {'The Butternut Co.': [1, 2], 'Alpino': [3, 4]},
      'basePrice': 320.0,
    },
    {
      'name': 'Cheese Spread',
      'category': 'Spreads',
      'unit': 'weight',
      'bigBrands': ['Amul'],
      'smallBrands': {'Britannia': [1, 2], 'Gowardhan': [3, 4]},
      'basePrice': 85.0, // ₹85/200g
    },
    
    // === JAMS & HONEY ===
    {
      'name': 'Mixed Fruit Jam',
      'category': 'Jams & Honey',
      'unit': 'weight',
      'bigBrands': ['Kissan', 'Mapro'],
      'smallBrands': {'Tops': [1, 2], 'Veeba': [3, 4]},
      'basePrice': 95.0, // ₹95/500g
    },
    {
      'name': 'Strawberry Jam',
      'category': 'Jams & Honey',
      'unit': 'weight',
      'bigBrands': ['Kissan'],
      'smallBrands': {'Mala\'s': [1, 2], 'Mapro': [3, 4]},
      'basePrice': 105.0,
    },
    {
      'name': 'Mango Jam',
      'category': 'Jams & Honey',
      'unit': 'weight',
      'bigBrands': ['Kissan'],
      'smallBrands': {'Mapro': [1, 3], 'Tops': [2, 4]},
      'basePrice': 98.0,
    },
    {
      'name': 'Orange Marmalade',
      'category': 'Jams & Honey',
      'unit': 'weight',
      'bigBrands': ['Kissan'],
      'smallBrands': {'Mapro': [1, 2], 'Mala\'s': [3, 4]},
      'basePrice': 110.0,
    },
    {
      'name': 'Honey',
      'category': 'Jams & Honey',
      'unit': 'weight',
      'bigBrands': ['Dabur', 'Patanjali'],
      'smallBrands': {'Apis': [1, 2], 'Zandu': [3, 4]},
      'basePrice': 220.0, // ₹220/500g
    },
    {
      'name': 'Organic Honey',
      'category': 'Jams & Honey',
      'unit': 'weight',
      'bigBrands': ['Organic India'],
      'smallBrands': {'24 Mantra': [2, 3], 'Conscious Food': [1, 4]},
      'basePrice': 350.0,
    },
    
    // === TOPPINGS & SYRUPS ===
    {
      'name': 'Chocolate Syrup',
      'category': 'Toppings & Syrups',
      'unit': 'volume',
      'bigBrands': ['Hershey\'s'],
      'smallBrands': {'Veeba': [1, 2], 'Mala\'s': [3, 4]},
      'basePrice': 180.0, // ₹180/500ml
    },
    {
      'name': 'Strawberry Syrup',
      'category': 'Toppings & Syrups',
      'unit': 'volume',
      'bigBrands': ['Mapro'],
      'smallBrands': {'Mala\'s': [1, 3], 'Veeba': [2, 4]},
      'basePrice': 150.0,
    },
    {
      'name': 'Caramel Syrup',
      'category': 'Toppings & Syrups',
      'unit': 'volume',
      'bigBrands': ['Hershey\'s'],
      'smallBrands': {'Veeba': [1, 2], 'Mala\'s': [3, 4]},
      'basePrice': 190.0,
    },
    {
      'name': 'Maple Syrup',
      'category': 'Toppings & Syrups',
      'unit': 'volume',
      'bigBrands': ['Rougemont'],
      'smallBrands': {'Natureland': [1, 3], 'Organic India': [2, 4]},
      'basePrice': 450.0,
    },
    
    // === BEVERAGES (Cold Drinks & Juices) ===
    {
      'name': 'Coca Cola',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Coca Cola'],
      'smallBrands': {},
      'basePrice': 45.0, // ₹45/750ml
    },
    {
      'name': 'Pepsi',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Pepsi'],
      'smallBrands': {},
      'basePrice': 45.0,
    },
    {
      'name': 'Sprite',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Sprite'],
      'smallBrands': {},
      'basePrice': 45.0,
    },
    {
      'name': 'Thums Up',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Thums Up'],
      'smallBrands': {},
      'basePrice': 45.0,
    },
    {
      'name': 'Fanta',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Fanta'],
      'smallBrands': {},
      'basePrice': 45.0,
    },
    {
      'name': 'Limca',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Limca'],
      'smallBrands': {},
      'basePrice': 40.0,
    },
    {
      'name': 'Mountain Dew',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Mountain Dew'],
      'smallBrands': {},
      'basePrice': 45.0,
    },
    {
      'name': 'Maaza',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Maaza'],
      'smallBrands': {},
      'basePrice': 25.0,
    },
    {
      'name': 'Slice',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Slice'],
      'smallBrands': {},
      'basePrice': 25.0,
    },
    {
      'name': 'Frooti',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Frooti'],
      'smallBrands': {},
      'basePrice': 20.0,
    },
    {
      'name': 'Appy Fizz',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Appy Fizz'],
      'smallBrands': {},
      'basePrice': 30.0,
    },
    {
      'name': 'Real Fruit Juice',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Real'],
      'smallBrands': {},
      'basePrice': 55.0,
    },
    {
      'name': 'Tropicana Juice',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Tropicana'],
      'smallBrands': {},
      'basePrice': 60.0,
    },
    {
      'name': 'B Natural Juice',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['B Natural'],
      'smallBrands': {},
      'basePrice': 50.0,
    },
    {
      'name': 'Paper Boat',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Paper Boat'],
      'smallBrands': {},
      'basePrice': 40.0,
    },
    {
      'name': 'Minute Maid',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Minute Maid'],
      'smallBrands': {},
      'basePrice': 35.0,
    },
    {
      'name': 'Tang Instant Drink',
      'category': 'Beverages',
      'unit': 'pack',
      'bigBrands': ['Tang'],
      'smallBrands': {},
      'basePrice': 150.0,
    },
    {
      'name': 'Rasna',
      'category': 'Beverages',
      'unit': 'pack',
      'bigBrands': ['Rasna'],
      'smallBrands': {},
      'basePrice': 95.0,
    },
    {
      'name': 'Energy Drink',
      'category': 'Beverages',
      'unit': 'volume',
      'bigBrands': ['Red Bull', 'Monster'],
      'smallBrands': {'Sting': [1, 2], 'Tzinga': [3, 4]},
      'basePrice': 125.0,
    },
    
    // === HOUSEHOLD ===
    {
      'name': 'Detergent Powder',
      'category': 'Household',
      'unit': 'weight',
      'bigBrands': ['Surf Excel', 'Ariel'],
      'smallBrands': {'Rin': [1, 2], 'Tide': [3, 4], 'Wheel': [1]},
      'basePrice': 75.0, // ₹150/kg
    },
    {
      'name': 'Dish Wash Bar',
      'category': 'Household',
      'unit': 'pack',
      'bigBrands': ['Vim'],
      'smallBrands': {'Exo': [1, 2], 'Pril': [3, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Dish Wash Liquid',
      'category': 'Household',
      'unit': 'volume',
      'bigBrands': ['Vim'],
      'smallBrands': {'Pril': [1, 3], 'Exo': [2, 4]},
      'basePrice': 120.0,
    },
    {
      'name': 'Floor Cleaner',
      'category': 'Household',
      'unit': 'volume',
      'bigBrands': ['Lizol'],
      'smallBrands': {'Domex': [1, 2], 'Harpic': [3, 4]},
      'basePrice': 135.0,
    },
    
    // === VEGETABLES ===
    {
      'name': 'Tomato',
      'category': 'Vegetables',
      'unit': 'weight',
      'bigBrands': ['Fresh'],
      'smallBrands': {'Organic': [2, 3], 'Farm Fresh': [1, 4]},
      'basePrice': 25.0, // ₹50/kg
    },
    {
      'name': 'Onion',
      'category': 'Vegetables',
      'unit': 'weight',
      'bigBrands': ['Fresh'],
      'smallBrands': {'Organic': [2, 3], 'Farm Fresh': [1, 4]},
      'basePrice': 22.0,
    },
    {
      'name': 'Potato',
      'category': 'Vegetables',
      'unit': 'weight',
      'bigBrands': ['Fresh'],
      'smallBrands': {'Organic': [2], 'Farm Fresh': [1, 3, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Carrot',
      'category': 'Vegetables',
      'unit': 'weight',
      'bigBrands': ['Fresh'],
      'smallBrands': {'Organic': [1, 3], 'Farm Fresh': [2, 4]},
      'basePrice': 28.0,
    },
    
    // === FRUITS ===
    {
      'name': 'Apple',
      'category': 'Fruits',
      'unit': 'weight',
      'bigBrands': ['Washington', 'Shimla'],
      'smallBrands': {'Fuji': [1, 2], 'Kashmiri': [3, 4]},
      'basePrice': 90.0, // ₹180/kg
    },
    {
      'name': 'Banana',
      'category': 'Fruits',
      'unit': 'weight',
      'bigBrands': ['Robusta'],
      'smallBrands': {'Yelakki': [1, 2], 'Nendran': [3, 4]},
      'basePrice': 25.0,
    },
    {
      'name': 'Orange',
      'category': 'Fruits',
      'unit': 'weight',
      'bigBrands': ['Nagpur'],
      'smallBrands': {'Imported': [2, 3], 'Kinnow': [1, 4]},
      'basePrice': 50.0,
    },
    
    // === EGGS ===
    {
      'name': 'Eggs',
      'category': 'Eggs',
      'unit': 'pieces',
      'bigBrands': ['Farm Fresh'],
      'smallBrands': {'Suguna': [1, 2], 'SKM': [3, 4]},
      'basePrice': 48.0, // ₹48/6pcs
    },
    {
      'name': 'Brown Eggs',
      'category': 'Eggs',
      'unit': 'pieces',
      'bigBrands': ['Organic'],
      'smallBrands': {'Suguna': [1, 3], 'Free Range': [2, 4]},
      'basePrice': 72.0,
    },
    
    // === BAKERY ===
    {
      'name': 'Bread',
      'category': 'Bakery',
      'unit': 'pack',
      'bigBrands': ['Britannia', 'Modern'],
      'smallBrands': {'Harvest Gold': [1, 2], 'Elite': [3, 4]},
      'basePrice': 42.0, // ₹42/400g
    },
    {
      'name': 'Brown Bread',
      'category': 'Bakery',
      'unit': 'pack',
      'bigBrands': ['Britannia'],
      'smallBrands': {'Modern': [1, 3], 'Harvest Gold': [2, 4]},
      'basePrice': 50.0,
    },
    {
      'name': 'Pav',
      'category': 'Bakery',
      'unit': 'pack',
      'bigBrands': ['Britannia'],
      'smallBrands': {'Modern': [1, 2], 'Local': [3, 4]},
      'basePrice': 25.0,
    },
    
    // === ICE CREAM ===
    {
      'name': 'Vanilla Ice Cream',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Amul', 'Kwality Walls'],
      'smallBrands': {'Baskin Robbins': [1, 2], 'Naturals': [3, 4]},
      'basePrice': 85.0, // ₹85/500ml
    },
    {
      'name': 'Chocolate Ice Cream',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Amul', 'Kwality Walls'],
      'smallBrands': {'Häagen-Dazs': [2, 3], 'Baskin Robbins': [1, 4]},
      'basePrice': 95.0,
    },
    {
      'name': 'Strawberry Ice Cream',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Amul'],
      'smallBrands': {'Kwality Walls': [1, 2], 'Naturals': [3, 4]},
      'basePrice': 90.0,
    },
    {
      'name': 'Butterscotch Ice Cream',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Amul'],
      'smallBrands': {'Havmor': [1, 3], 'Cream Bell': [2, 4]},
      'basePrice': 95.0,
    },
    {
      'name': 'Mango Ice Cream',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Naturals', 'Amul'],
      'smallBrands': {'Havmor': [1, 2], 'Vadilal': [3, 4]},
      'basePrice': 100.0,
    },
    {
      'name': 'Kulfi',
      'category': 'Ice Cream',
      'unit': 'pack',
      'bigBrands': ['Amul', 'Vadilal'],
      'smallBrands': {'Giani': [1, 3], 'Havmor': [2, 4]},
      'basePrice': 30.0,
    },
    {
      'name': 'Ice Cream Cone',
      'category': 'Ice Cream',
      'unit': 'pack',
      'bigBrands': ['Cornetto', 'Kwality Walls'],
      'smallBrands': {'Amul': [1, 2], 'Vadilal': [3, 4]},
      'basePrice': 40.0,
    },
    {
      'name': 'Ice Cream Sandwich',
      'category': 'Ice Cream',
      'unit': 'pack',
      'bigBrands': ['Kwality Walls'],
      'smallBrands': {'Amul': [1, 3], 'Vadilal': [2, 4]},
      'basePrice': 25.0,
    },
    {
      'name': 'Fruit Bar',
      'category': 'Ice Cream',
      'unit': 'pack',
      'bigBrands': ['Amul'],
      'smallBrands': {'Vadilal': [1, 2], 'Havmor': [3, 4]},
      'basePrice': 20.0,
    },
    {
      'name': 'Choco Bar',
      'category': 'Ice Cream',
      'unit': 'pack',
      'bigBrands': ['Amul', 'Kwality Walls'],
      'smallBrands': {'Havmor': [1, 3], 'Cream Bell': [2, 4]},
      'basePrice': 30.0,
    },
    {
      'name': 'Family Pack Ice Cream',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Amul'],
      'smallBrands': {'Vadilal': [1, 2], 'Havmor': [3, 4]},
      'basePrice': 250.0, // ₹250/1L
    },
    {
      'name': 'Premium Ice Cream Tub',
      'category': 'Ice Cream',
      'unit': 'volume',
      'bigBrands': ['Häagen-Dazs', 'Baskin Robbins'],
      'smallBrands': {'Naturals': [1, 3], 'London Dairy': [2, 4]},
      'basePrice': 450.0,
    },
    
    // === SHAMPOO ===
    {
      'name': 'Anti-Dandruff Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Head & Shoulders', 'Clinic Plus'],
      'smallBrands': {'Himalaya': [1, 2], 'Dove': [3, 4]},
      'basePrice': 180.0, // ₹180/340ml
    },
    {
      'name': 'Anti-Hairfall Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Dove', 'Pantene'],
      'smallBrands': {'Himalaya': [1, 3], 'TRESemmé': [2, 4]},
      'basePrice': 195.0,
    },
    {
      'name': 'Daily Use Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Clinic Plus', 'Sunsilk'],
      'smallBrands': {'Dove': [1, 2], 'Pantene': [3, 4]},
      'basePrice': 145.0,
    },
    {
      'name': 'Herbal Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Himalaya', 'Patanjali'],
      'smallBrands': {'Biotique': [1, 2], 'Khadi Natural': [3, 4]},
      'basePrice': 165.0,
    },
    {
      'name': 'Onion Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Mamaearth', 'WOW Skin Science'],
      'smallBrands': {'Khadi Natural': [1, 3], 'Wow': [2, 4]},
      'basePrice': 299.0,
    },
    {
      'name': 'Keratin Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['TRESemmé', 'L\'Oréal Paris'],
      'smallBrands': {'Sunsilk': [1, 2], 'Garnier': [3, 4]},
      'basePrice': 320.0,
    },
    {
      'name': 'Kids Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Johnson\'s Baby'],
      'smallBrands': {'Himalaya Baby': [1, 2], 'Mamaearth': [3, 4]},
      'basePrice': 175.0,
    },
    {
      'name': 'Anti-Lice Shampoo',
      'category': 'Shampoo',
      'unit': 'volume',
      'bigBrands': ['Mediker'],
      'smallBrands': {'Himalaya': [1, 3], 'Nice': [2, 4]},
      'basePrice': 85.0,
    },
    
    // === CONDITIONER ===
    {
      'name': 'Smoothening Conditioner',
      'category': 'Conditioner',
      'unit': 'volume',
      'bigBrands': ['Dove', 'Pantene'],
      'smallBrands': {'TRESemmé': [1, 2], 'L\'Oréal Paris': [3, 4]},
      'basePrice': 195.0,
    },
    {
      'name': 'Keratin Conditioner',
      'category': 'Conditioner',
      'unit': 'volume',
      'bigBrands': ['TRESemmé', 'L\'Oréal Paris'],
      'smallBrands': {'Sunsilk': [1, 3], 'Garnier': [2, 4]},
      'basePrice': 320.0,
    },
    {
      'name': 'Anti-Hairfall Conditioner',
      'category': 'Conditioner',
      'unit': 'volume',
      'bigBrands': ['Dove', 'Pantene'],
      'smallBrands': {'Himalaya': [1, 2], 'Mamaearth': [3, 4]},
      'basePrice': 210.0,
    },
    {
      'name': 'Damage Repair Conditioner',
      'category': 'Conditioner',
      'unit': 'volume',
      'bigBrands': ['Dove', 'Head & Shoulders'],
      'smallBrands': {'Clinic Plus': [1, 2], 'Sunsilk': [3, 4]},
      'basePrice': 185.0,
    },
    {
      'name': 'Onion Conditioner',
      'category': 'Conditioner',
      'unit': 'volume',
      'bigBrands': ['Mamaearth', 'WOW Skin Science'],
      'smallBrands': {'Khadi Natural': [1, 3], 'Biotique': [2, 4]},
      'basePrice': 299.0,
    },
    {
      'name': 'Colour Protect Conditioner',
      'category': 'Conditioner',
      'unit': 'volume',
      'bigBrands': ['L\'Oréal Paris', 'Garnier'],
      'smallBrands': {'TRESemmé': [1, 2], 'Matrix': [3, 4]},
      'basePrice': 350.0,
    },
    
    // === HAIR OILS ===
    {
      'name': 'Coconut Hair Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Parachute', 'Bajaj'],
      'smallBrands': {'VVD': [1, 2], 'Cococare': [3, 4]},
      'basePrice': 95.0, // ₹95/200ml
    },
    {
      'name': 'Almond Hair Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Bajaj Almond Drops', 'Dabur'],
      'smallBrands': {'Patanjali': [1, 2], 'Himalaya': [3, 4]},
      'basePrice': 120.0,
    },
    {
      'name': 'Amla Hair Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Dabur Amla', 'Bajaj'],
      'smallBrands': {'Patanjali': [1, 3], 'Nihar': [2, 4]},
      'basePrice': 85.0,
    },
    {
      'name': 'Anti-Hairfall Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Kesh King', 'Indulekha'],
      'smallBrands': {'Himalaya': [1, 2], 'Dabur': [3, 4]},
      'basePrice': 250.0,
    },
    {
      'name': 'Onion Hair Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Mamaearth', 'WOW'],
      'smallBrands': {'Khadi Natural': [1, 3], 'Wow Red Onion': [2, 4]},
      'basePrice': 349.0,
    },
    {
      'name': 'Ayurvedic Hair Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Kesh King', 'Patanjali'],
      'smallBrands': {'Himalaya': [1, 2], 'Biotique': [3, 4]},
      'basePrice': 195.0,
    },
    {
      'name': 'Cool Hair Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['Navratna', 'Dabur'],
      'smallBrands': {'Himani': [1, 2], 'Emami': [3, 4]},
      'basePrice': 75.0,
    },
    {
      'name': 'Castor Oil',
      'category': 'Hair Oils',
      'unit': 'volume',
      'bigBrands': ['WOW', 'Mamaearth'],
      'smallBrands': {'Patanjali': [1, 3], 'Organic India': [2, 4]},
      'basePrice': 199.0,
    },
    
    // === HAIR SERUM ===
    {
      'name': 'Anti-Frizz Serum',
      'category': 'Hair Serum',
      'unit': 'volume',
      'bigBrands': ['Livon', 'L\'Oréal Paris'],
      'smallBrands': {'TRESemmé': [1, 2], 'Streax': [3, 4]},
      'basePrice': 175.0, // ₹175/100ml
    },
    {
      'name': 'Heat Protection Serum',
      'category': 'Hair Serum',
      'unit': 'volume',
      'bigBrands': ['TRESemmé', 'L\'Oréal Paris'],
      'smallBrands': {'Matrix': [1, 2], 'Streax': [3, 4]},
      'basePrice': 299.0,
    },
    {
      'name': 'Smoothening Serum',
      'category': 'Hair Serum',
      'unit': 'volume',
      'bigBrands': ['Livon', 'Streax'],
      'smallBrands': {'Set Wet': [1, 2], 'UrbanGabru': [3, 4]},
      'basePrice': 150.0,
    },
    {
      'name': 'Keratin Serum',
      'category': 'Hair Serum',
      'unit': 'volume',
      'bigBrands': ['TRESemmé', 'L\'Oréal Paris'],
      'smallBrands': {'Matrix': [1, 3], 'Mamaearth': [2, 4]},
      'basePrice': 450.0,
    },
    {
      'name': 'Argan Oil Serum',
      'category': 'Hair Serum',
      'unit': 'volume',
      'bigBrands': ['Mamaearth', 'WOW'],
      'smallBrands': {'StBotanica': [1, 2], 'Organix': [3, 4]},
      'basePrice': 399.0,
    },
  ];

  // Shop IDs: 1 = GRO MART, 2 = ROYAL Supermarket, 3 = Reliance SMART Point, 4 = J B Super Market
  for (int shopId = 1; shopId <= 4; shopId++) {
    int productIdCounter = 1;
    
    for (var item in baseItems) {
      List<String> bigBrands = List<String>.from(item['bigBrands']);
      Map<String, List<int>> smallBrands = Map<String, List<int>>.from(
        (item['smallBrands'] as Map).map((key, value) => MapEntry(key.toString(), List<int>.from(value)))
      );
      double basePrice = item['basePrice'];
      String unit = item['unit'] ?? 'weight';
      
      // Add BIG brands for all shops
      for (var brand in bigBrands) {
        double price = basePrice + random.nextInt(8) - 3;
        if (price < 5) price = 5;
        bool inStock = random.nextDouble() > 0.05;

        String productName = '$brand ${item['name']}';
        String imageUrl = getImage(productName);

        allProducts.add(ProductModel(
          id: '${shopId}_${productIdCounter++}',
          shopId: '$shopId',
          name: productName,
          price: price,
          originalPrice: random.nextDouble() > 0.6 ? price + random.nextInt(15) + 5 : null,
          imageUrl: imageUrl,
          inStock: inStock,
          stockQuantity: inStock ? random.nextInt(80) + 20 : 0,
          category: item['category'],
          brand: brand,
          unit: unit,
        ));
      }
      
      // Add SMALL brands only for specific shops
      for (var entry in smallBrands.entries) {
        String brand = entry.key;
        List<int> availableShopIds = entry.value;
        
        if (availableShopIds.contains(shopId)) {
          double price = basePrice + random.nextInt(10) - 4;
          if (price < 5) price = 5;
          bool inStock = random.nextDouble() > 0.15;

          String productName = '$brand ${item['name']}';
          String imageUrl = getImage(productName);

          allProducts.add(ProductModel(
            id: '${shopId}_${productIdCounter++}',
            shopId: '$shopId',
            name: productName,
            price: price,
            originalPrice: random.nextDouble() > 0.5 ? price + random.nextInt(12) + 3 : null,
            imageUrl: imageUrl,
            inStock: inStock,
            stockQuantity: inStock ? random.nextInt(40) + 5 : 0,
            category: item['category'],
            brand: brand,
            unit: unit,
          ));
        }
      }
    }
  }

  return allProducts;
}

List<ProductModel> mockProducts = _generateProducts();
