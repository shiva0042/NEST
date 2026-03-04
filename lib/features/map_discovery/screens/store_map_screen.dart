// ignore_for_file: undefined_prefixed_name, avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/store_provider.dart';
import '../models/shop_model.dart';
import 'shop_details_view.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  ShopModel? _selectedShop;
  final MapController _mapController = MapController();
  
  // Trichy center coordinates
  static const LatLng _trichyCenter = LatLng(10.8065, 78.6900);

  void _selectShop(ShopModel shop) {
    setState(() {
      _selectedShop = shop;
    });
    _mapController.move(LatLng(shop.latitude, shop.longitude), 16);
  }

  void _centerOnTrichy() {
    setState(() {
      _selectedShop = null;
    });
    _mapController.move(_trichyCenter, 13);
  }

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<StoreProvider>().shops;
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: const Text(
          'Store Locations',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _centerOnTrichy,
            tooltip: 'Show All Stores',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded),
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, currentZoom + 1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded),
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, currentZoom - 1);
            },
          ),
        ],
      ),
      body: isWeb ? _buildWebLayout(shops) : _buildMobileLayout(shops),
    );
  }

  Widget _buildWebLayout(List<ShopModel> shops) {
    return Row(
      children: [
        // Store List Panel
        StatefulBuilder(builder: (context, setListState) {
          return ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.5))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${shops.length} Stores Found',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View and navigate to local stores',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          final shop = shops[index];
                          final isSelected = _selectedShop?.id == shop.id;
                          return _StoreListItem(
                            shop: shop,
                            isSelected: isSelected,
                            onTap: () => _selectShop(shop),
                            onViewDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ShopDetailsView(shop: shop)),
                              );
                            },
                            onOpenMap: () => _openInGoogleMaps(shop),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        // Map Area
        Expanded(
          child: Stack(
            children: [
              // Interactive Overview Map with ALL PINS
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _trichyCenter,
                  initialZoom: 13,
                  onTap: (_, __) {
                    setState(() => _selectedShop = null);
                  },
                ),
                children: [
                  // High Quality Map Tiles
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.near_basket',
                  ),
                  // PIN ALL STORES
                  MarkerLayer(
                    markers: shops.map((shop) {
                      final isSelected = _selectedShop?.id == shop.id;
                      return Marker(
                        point: LatLng(shop.latitude, shop.longitude),
                        width: 100,
                        height: 100,
                        child: GestureDetector(
                          onTap: () => _selectShop(shop),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isSelected ? 1.0 : 0.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  child: Text(
                                    shop.name,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on_rounded,
                                color: isSelected ? Colors.blue : (shop.isOpen ? Colors.green : Colors.red),
                                size: isSelected ? 40 : 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              
              // DEEP DIVE: Google Maps Iframe for selected store
              if (_selectedShop != null)
                Positioned(
                  top: 20,
                  right: 20,
                  width: 350,
                  height: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: AppColors.primary,
                          child: Row(
                            children: [
                              const Icon(Icons.visibility, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'Visual Confirmation',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _selectedShop = null),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _GoogleMapIframeDetailed(
                            lat: _selectedShop!.latitude,
                            lng: _selectedShop!.longitude,
                            shopName: _selectedShop!.name,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selected Store Info Card (Bottom)
              if (_selectedShop != null)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: _SelectedStoreCard(
                    shop: _selectedShop!,
                    onClose: () => setState(() => _selectedShop = null),
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ShopDetailsView(shop: _selectedShop!)),
                      );
                    },
                    onOpenMap: () => _openInGoogleMaps(_selectedShop!),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<ShopModel> shops) {
    return Stack(
      children: [
        // Map Overview
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _trichyCenter,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: shops.map((shop) => Marker(
                point: LatLng(shop.latitude, shop.longitude),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _selectShop(shop),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: _selectedShop?.id == shop.id ? Colors.blue : (shop.isOpen ? Colors.green : Colors.red),
                    size: _selectedShop?.id == shop.id ? 45 : 35,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
        // Draggable List
        DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.12,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: shops.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildMobileHandle();
                      final shop = shops[index - 1];
                      return _MobileStoreCard(
                        shop: shop,
                        isSelected: _selectedShop?.id == shop.id,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsView(shop: shop))),
                        onLocate: () {
                          _selectShop(shop);
                        },
                        onOpenMap: () => _openInGoogleMaps(shop),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileHandle() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Nearby Stores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Future<void> _openInGoogleMaps(ShopModel shop) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${shop.latitude},${shop.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

// Special Iframe widget that uses the output=embed trick for pinpoint accuracy
class _GoogleMapIframeDetailed extends StatelessWidget {
  final double lat;
  final double lng;
  final String shopName;

  const _GoogleMapIframeDetailed({
    required this.lat,
    required this.lng,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    final String viewId = 'google-map-iframe-$lat-$lng';
    final String embedUrl = 'https://maps.google.com/maps?q=$lat,$lng&hl=en&z=17&output=embed';

    // ignore: undefined_prefixed_name
    // ignore: unsafe_html
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return HtmlElementView(viewType: viewId);
  }
}

// Store List Item Widget
class _StoreListItem extends StatelessWidget {
  final ShopModel shop;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;
  final VoidCallback onOpenMap;

  const _StoreListItem({
    required this.shop,
    required this.isSelected,
    required this.onTap,
    required this.onViewDetails,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(shop.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(shop.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.orange),
                      Text(shop.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 12),
                      Text('${shop.distance} km', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Selected Store Card
class _SelectedStoreCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final VoidCallback onOpenMap;

  const _SelectedStoreCard({
    required this.shop,
    required this.onClose,
    required this.onViewDetails,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(shop.imageUrl, width: 80, height: 80, fit: BoxFit.cover)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(shop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(shop.address, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                  ElevatedButton.icon(
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mobile Store Card
class _MobileStoreCard extends StatelessWidget {
  final ShopModel shop;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLocate;
  final VoidCallback onOpenMap;

  const _MobileStoreCard({
    required this.shop,
    required this.isSelected,
    required this.onTap,
    required this.onLocate,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200)),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(shop.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(shop.address, style: const TextStyle(fontSize: 12), maxLines: 1),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.my_location, color: isSelected ? AppColors.primary : Colors.grey), onPressed: onLocate),
          ],
        ),
      ),
    );
  }
}
