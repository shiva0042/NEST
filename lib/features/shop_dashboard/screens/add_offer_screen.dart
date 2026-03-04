import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../../map_discovery/models/product_model.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String _offerTitle = '';
  double _discountPercentage = 0;
  String _offerType = 'Percentage Off';
  DateTime? _startDate;
  DateTime? _endDate;
  double _minOrderValue = 0;
  List<ProductModel> _selectedProducts = [];
  
  final List<String> _offerTypes = [
    'Percentage Off',
    'Fixed Amount Off',
    'Buy 1 Get 1',
    'Combo Offer',
    'Free Delivery',
  ];

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showProductSelectionDialog() {
    final shopId = context.read<StoreProvider>().currentShopId;
    final availableProducts = mockProducts.where((p) => p.shopId == shopId).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductSelectionSheet(
        availableProducts: availableProducts,
        selectedProducts: _selectedProducts,
        onSelectionChanged: (selected) {
          setState(() {
            _selectedProducts = selected;
          });
        },
      ),
    );
  }

  void _saveOffer() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Validation for Combo Offers
      if (_offerType == 'Combo Offer' && _selectedProducts.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Combo offers require at least 2 products'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one product for the offer'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer "$_offerTitle" created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'Create New Offer',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Offer Title
            _buildSectionTitle('Offer Details'),
            const SizedBox(height: 12),
            TextFormField(
              decoration: _buildInputDecoration('Offer Title', Icons.local_offer),
              validator: (val) => val?.isEmpty ?? true ? 'Please enter offer title' : null,
              onSaved: (val) => _offerTitle = val ?? '',
            ),
            const SizedBox(height: 16),
            
            // Offer Type
            DropdownButtonFormField<String>(
              initialValue: _offerType,
              decoration: _buildInputDecoration('Offer Type', Icons.category),
              items: _offerTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _offerType = val!),
            ),
            const SizedBox(height: 16),
            
            // Discount Percentage
            if (_offerType == 'Percentage Off' || _offerType == 'Fixed Amount Off')
              TextFormField(
                decoration: _buildInputDecoration(
                  _offerType == 'Percentage Off' ? 'Discount (%)' : 'Discount Amount (₹)',
                  Icons.percent,
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter discount value';
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) return 'Please enter valid amount';
                  if (_offerType == 'Percentage Off' && num > 100) return 'Cannot exceed 100%';
                  return null;
                },
                onSaved: (val) => _discountPercentage = double.tryParse(val ?? '0') ?? 0,
              ),
            const SizedBox(height: 24),
            
            // Date Range
            _buildSectionTitle('Validity Period'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                ),
                                Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                ),
                                Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Minimum Order Value
            _buildSectionTitle('Conditions'),
            const SizedBox(height: 12),
            TextFormField(
              decoration: _buildInputDecoration('Minimum Order Value (₹)', Icons.shopping_cart),
              keyboardType: TextInputType.number,
              initialValue: '0',
              onSaved: (val) => _minOrderValue = double.tryParse(val ?? '0') ?? 0,
            ),
            const SizedBox(height: 24),
            
            // Product Selection Section (always shown)
            _buildSectionTitle(
              _offerType == 'Combo Offer' 
                ? 'Combo Products (${_selectedProducts.length})' 
                : 'Selected Products (${_selectedProducts.length})'
            ),
            const SizedBox(height: 12),
              
            // Info message for combo offers
            if (_offerType == 'Combo Offer')
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select products to bundle in this combo offer',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Select Products Button
            InkWell(
              onTap: _showProductSelectionDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Select Products',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Selected Products List
            if (_selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...(_selectedProducts.map((product) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedProducts.remove(product);
                        });
                      },
                    ),
                  ],
                ),
              )).toList()),
            ],
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Create Offer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

// Product Selection Bottom Sheet
class _ProductSelectionSheet extends StatefulWidget {
  final List<ProductModel> availableProducts;
  final List<ProductModel> selectedProducts;
  final Function(List<ProductModel>) onSelectionChanged;

  const _ProductSelectionSheet({
    required this.availableProducts,
    required this.selectedProducts,
    required this.onSelectionChanged,
  });

  @override
  State<_ProductSelectionSheet> createState() => _ProductSelectionSheetState();
}

class _ProductSelectionSheetState extends State<_ProductSelectionSheet> {
  late List<ProductModel> _tempSelected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedProducts);
  }

  List<ProductModel> get _filteredProducts {
    return widget.availableProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      '${_tempSelected.length} selected',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Select All / Deselect All Button
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_tempSelected.length == widget.availableProducts.length) {
                        // Deselect all
                        _tempSelected.clear();
                      } else {
                        // Select all
                        _tempSelected = List.from(widget.availableProducts);
                      }
                    });
                  },
                  icon: Icon(
                    _tempSelected.length == widget.availableProducts.length 
                      ? Icons.deselect 
                      : Icons.select_all,
                    size: 20,
                  ),
                  label: Text(
                    _tempSelected.length == widget.availableProducts.length 
                      ? 'Deselect All' 
                      : 'Select All',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Search bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Product List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final isSelected = _tempSelected.any((p) => p.id == product.id);
                
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _tempSelected.add(product);
                      } else {
                        _tempSelected.removeWhere((p) => p.id == product.id);
                      }
                    });
                  },
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  secondary: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  activeColor: AppColors.primary,
                );
              },
            ),
          ),
          // Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelectionChanged(_tempSelected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Confirm Selection (${_tempSelected.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
