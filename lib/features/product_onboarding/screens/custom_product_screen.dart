import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/catalog_service.dart';

class CustomProductScreen extends StatefulWidget {
  const CustomProductScreen({super.key});

  @override
  State<CustomProductScreen> createState() => _CustomProductScreenState();
}

class _CustomProductScreenState extends State<CustomProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final CatalogService _catalogService = CatalogService();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  String _selectedUnit = 'ml';
  String _selectedVariant = 'Pack';

  List<Product> _suggestions = [];
  bool _imageSelected = false;

  final List<String> _units = ['ml', 'L', 'g', 'kg', 'pcs', 'pack'];
  final List<String> _variants = ['Pouch', 'TetraPack', 'Packet', 'Bottle', 'Loaf', 'Pack', 'Can', 'Box'];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _barcodeController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Debounce logic could be added here
    if (_nameController.text.length > 2 || _barcodeController.text.isNotEmpty) {
      _fetchSuggestions();
    }
  }

  Future<void> _fetchSuggestions() async {
    final results = await _catalogService.autoSuggest(_nameController.text, _barcodeController.text);
    if (mounted) {
      setState(() {
        _suggestions = results;
      });
    }
  }

  void _useSuggestion(Product product) {
    // Auto-fill form or just select it
    _nameController.text = product.canonicalName;
    _brandController.text = product.brand;
    _sizeController.text = product.sizeValue.toString();
    _selectedUnit = product.sizeUnit;
    _selectedVariant = product.variant;
    _barcodeController.text = product.barcode ?? '';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filled details from catalog match!")),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Parse size
      final sizeData = SizeParser.parse('${_sizeController.text} $_selectedUnit');
      
      final candidate = CustomProductCandidate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shopId: 'shop_123', // Mock
        name: _nameController.text,
        brand: _brandController.text,
        variant: _selectedVariant,
        size: sizeData['canonical'],
        barcode: _barcodeController.text,
        price: double.tryParse(_priceController.text),
        imageUrl: _imageSelected ? 'path/to/image.jpg' : null,
        status: 'pending',
        tags: [],
      );

      await _catalogService.addCustomProduct(candidate);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Custom product submitted for review!")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Custom Product")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Upload Placeholder
            GestureDetector(
              onTap: () {
                setState(() => _imageSelected = !_imageSelected);
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Center(
                  child: _imageSelected 
                    ? const Icon(Icons.check_circle, size: 50, color: Colors.green)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          Text("Tap to upload photo"),
                        ],
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Auto-Suggest Panel
            if (_suggestions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Found in Master Catalog:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    ..._suggestions.map((p) => ListTile(
                      title: Text(p.canonicalName),
                      subtitle: Text("${p.brand} • ${p.canonicalSize}"),
                      trailing: ElevatedButton(
                        onPressed: () => _useSuggestion(p),
                        child: const Text("Use"),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Product Name *", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: "Brand", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedVariant,
                    decoration: const InputDecoration(labelText: "Variant", border: OutlineInputBorder()),
                    items: _variants.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setState(() => _selectedVariant = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Size", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(labelText: "Unit", border: OutlineInputBorder()),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _selectedUnit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: "Barcode (Optional)", 
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // Mock Scan
                    _barcodeController.text = "8901234567890";
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price (Optional)", border: OutlineInputBorder(), prefixText: "₹ "),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _submit,
              child: const Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }
}
