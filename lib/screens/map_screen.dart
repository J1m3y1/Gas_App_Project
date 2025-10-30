import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './gas_station.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  List<GasStation> gasStations = [];
  bool isMapReady = false;
  
  final DraggableScrollableController sheetController = DraggableScrollableController();

  // Example coordinate (LSU campus)
  final LatLng _center = const LatLng(30.4133, -91.1823);

  @override
  void initState() {
    super.initState();
    gasStations = getSampleGasStations();
    _createMarkers();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          isMapReady = true;
        });
      }
    });
  }

  void _createMarkers() {
    markers = gasStations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: '\$${station.cheapestPrice.toStringAsFixed(2)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    const String style = '''
    [
      {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    ]
    ''';
    mapController?.setMapStyle(style);
  }

  void _toggleSheet() {
    double newSize;
    final currentSize = sheetController.size;
    
    if (currentSize <= 0.1) {
      newSize = 0.5;
    } else if (currentSize < 0.7) {
      newSize = 0.8;
    } else {
      newSize = 0.05;
    }
    
    // Animate to new size
    if (sheetController.isAttached) {
      sheetController.animateTo(
        newSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            // Add padding to bottom so controls don't overlap with sheet
            padding: const EdgeInsets.only(bottom: 100),
          ),
          
          // Draggable Bottom Sheet
          if (isMapReady)
            DraggableScrollableSheet(
              controller: sheetController,
              initialChildSize: 0.05,
              minChildSize: 0.05,
              maxChildSize: 0.8,
              snap: true,
              snapSizes: const [0.05, 0.5, 0.8],
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Draggable header area
                      GestureDetector(
                        onVerticalDragUpdate: (details) {
                          // Manual drag handling
                          if (sheetController.isAttached) {
                            final currentSize = sheetController.size;
                            final delta = details.primaryDelta! / MediaQuery.of(context).size.height;
                            final newSize = (currentSize - delta).clamp(0.05, 0.8);
                            sheetController.jumpTo(newSize);
                          }
                        },
                        onVerticalDragEnd: (details) {
                          // Snap to nearest size
                          if (sheetController.isAttached) {
                            final currentSize = sheetController.size;
                            double snapTo;
                            
                            if (currentSize < 0.25) {
                              snapTo = 0.05;
                            } else if (currentSize < 0.65) {
                              snapTo = 0.5;
                            } else {
                              snapTo = 0.8;
                            }
                            
                            sheetController.animateTo(
                              snapTo,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Drag handle bar
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              
                              // Header with expand/collapse buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nearby Gas Stations',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${gasStations.length} stations',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Expand/Collapse buttons for web
                                    if (kIsWeb)
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.expand_less),
                                            onPressed: () {
                                              if (sheetController.isAttached) {
                                                sheetController.animateTo(
                                                  0.05,
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                            tooltip: 'Collapse',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.expand_more),
                                            onPressed: () {
                                              if (sheetController.isAttached) {
                                                sheetController.animateTo(
                                                  0.8,
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                            tooltip: 'Expand',
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              
                              const Divider(height: 1),
                            ],
                          ),
                        ),
                      ),
                      
                      // Gas Stations List
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: gasStations.length,
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final station = gasStations[index];
                            return GasStationCard(
                              station: station,
                              onTap: () {
                                // Move map camera to station location
                                if (mapController != null) {
                                  mapController!.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(station.latitude, station.longitude),
                                      16.0,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    sheetController.dispose();
    super.dispose();
  }
}

// Gas Station Card Widget
class GasStationCard extends StatelessWidget {
  final GasStation station;
  final VoidCallback onTap;

  const GasStationCard({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_gas_station,
                color: Colors.blue[700],
                size: 28,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Station Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${station.distance.toStringAsFixed(1)} mi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    station.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: station.prices.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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