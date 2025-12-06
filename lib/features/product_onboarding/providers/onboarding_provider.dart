import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/catalog_service.dart';

class OnboardingProvider with ChangeNotifier {
  final CatalogService _catalogService = CatalogService();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedSubcategory;
  String? get selectedSubcategory => _selectedSubcategory;

  String? _selectedProductType;
  String? get selectedProductType => _selectedProductType;

  String? _selectedBrand;
  String? get selectedBrand => _selectedBrand;

  List<Product> _availableVariants = [];
  List<Product> get availableVariants => _availableVariants;

  final Set<String> _selectedProductIds = {};
  Set<String> get selectedProductIds => _selectedProductIds;

  // Batch / Cart Functionality
  final List<Product> _batchProducts = [];
  List<Product> get batchProducts => _batchProducts;

  final Map<String, double> _selectedProductPrices = {};
  Map<String, double> get selectedProductPrices => _selectedProductPrices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Data Lists
  List<String> categories = [];
  List<String> subcategories = [];
  List<String> productTypes = [];
  List<String> brands = [];

  OnboardingProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();
    categories = await _catalogService.getCategories();
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) async {
    _selectedCategory = category;
    _currentStep = 1;
    _isLoading = true;
    notifyListeners();
    subcategories = await _catalogService.getSubcategories(category);
    _isLoading = false;
    notifyListeners();
  }

  void selectSubcategory(String subcategory) async {
    _selectedSubcategory = subcategory;
    _currentStep = 2; // Assuming Product Type selection is next or skipped to Brand if implicit
    // For this flow, let's say Category -> Subcategory -> Product Type -> Brand -> Size
    // But requirements say: Category -> Subcategory -> Brand -> Size (Step 3: Choose brand under subcategory)
    // However, Product Type is also mentioned. Let's infer Product Type is part of Subcategory or a step between.
    // "Step 3: Choose brand under the subcategory."
    // "For each product type, allow: Brand selection... Variant selection... Size selection"
    // I'll add a Product Type step if subcategory has multiple types.
    
    _isLoading = true;
    notifyListeners();
    productTypes = await _catalogService.getProductTypes(subcategory);
    if (productTypes.isNotEmpty) {
       _currentStep = 2; // Go to Product Type
    } else {
       _currentStep = 3; // Skip to Brand
       _loadBrands();
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectProductType(String type) async {
    _selectedProductType = type;
    _currentStep = 3;
    _loadBrands();
  }

  void _loadBrands() async {
    _isLoading = true;
    notifyListeners();
    if (_selectedCategory != null) {
       // We need to cast or ensure the service has this method. 
       // Since I updated the class directly, it's fine.
       brands = await _catalogService.getBrandsForCategory(_selectedCategory!);
    } else {
       brands = await _catalogService.getBrands();
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectBrand(String brand) async {
    _selectedBrand = brand;
    _currentStep = 4;
    _isLoading = true;
    notifyListeners();
    // Fetch variants for this Brand + Product Type (or Subcategory if no type)
    // Since mock service needs type, we assume one is selected or we fetch all for brand in subcategory
    String type = _selectedProductType ?? ''; 
    _availableVariants = await _catalogService.getProductsByBrandAndType(brand, type);
    _isLoading = false;
    notifyListeners();
  }

  void toggleProductSelection(String productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }
    notifyListeners();
  }

  void setPrice(String productId, double price) {
    _selectedProductPrices[productId] = price;
    notifyListeners();
  }

  void addToBatch() {
    // Convert selected IDs to Product objects
    final newItems = _availableVariants
        .where((p) => _selectedProductIds.contains(p.id))
        .toList();
    
    // Avoid duplicates
    for (var item in newItems) {
      if (!_batchProducts.any((p) => p.id == item.id)) {
        _batchProducts.add(item);
      }
    }
    
    // Clear selections for next batch
    _selectedProductIds.clear();
    notifyListeners();
  }

  void removeFromBatch(String productId) {
    _batchProducts.removeWhere((p) => p.id == productId);
    _selectedProductPrices.remove(productId);
    notifyListeners();
  }

  Future<void> saveBatch(String shopId) async {
    _isLoading = true;
    notifyListeners();
    
    for (var product in _batchProducts) {
      await _catalogService.addShopProduct(
        ShopProduct(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          shopId: shopId,
          productId: product.id,
          price: _selectedProductPrices[product.id],
          source: 'catalog',
          catalogStatus: 'approved',
        ),
        productDetails: product,
      );
    }
    
    _batchProducts.clear();
    _selectedProductPrices.clear();
    _isLoading = false;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      // Clear selections based on step we are going back TO
      // If going back to 0 (Category), clear Category selection
      if (_currentStep == 0) _selectedCategory = null;
      if (_currentStep == 1) _selectedSubcategory = null;
      if (_currentStep == 2) _selectedProductType = null;
      if (_currentStep == 3) _selectedBrand = null;
      
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 0;
    _selectedCategory = null;
    _selectedSubcategory = null;
    _selectedProductType = null;
    _selectedBrand = null;
    _selectedProductIds.clear();
    _selectedProductPrices.clear();
    // _batchProducts.clear(); // Don't clear batch on reset, user might want to keep them
    _availableVariants.clear();
    notifyListeners();
  }
  
  // Custom Product Logic
  Future<List<Product>> checkAutoSuggest(String name, String? barcode) {
    return _catalogService.autoSuggest(name, barcode);
  }
  
  Future<void> submitCustomProduct(CustomProductCandidate candidate) async {
    _isLoading = true;
    notifyListeners();
    await _catalogService.addCustomProduct(candidate);
    _isLoading = false;
    notifyListeners();
  }
}
