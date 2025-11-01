import 'package:flutter/material.dart';
import 'package:gas_app_project_dev/services/gas_station.dart';
import 'package:gas_app_project_dev/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gas_app_project_dev/services/gas_station_services.dart';

class MapScreen extends StatefulWidget {
  final bool isDarkMode;
  const MapScreen({super.key, required this.isDarkMode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? _userPosition;
  bool isMapReady = false;
  List<GasStation> gasStations = [];
  Set<Marker> markers = {};

  final DraggableScrollableController sheetController = DraggableScrollableController();
  final GasStationServices firestoreService = GasStationServices();
  @override
  void initState() {
    super.initState();
    getUserLocation();
    _fetchGasStations();
  }

  Future<void> _fetchGasStations() async {
  try {
    final snapshot = await firestoreService.getGasInfo().first;
    final stations = snapshot.docs
        .map((doc) => GasStation.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    setState(() {
      gasStations = stations;
      _createMarkers(); // create markers for the map
    });
  } catch (e) {
    print("Error fetching gas stations: $e");
  }
}

  Future<void> getUserLocation() async {
    try {
      final locationService = LocationService();
      final pos = await locationService.getCurrentLocation();

      setState(() {
        _userPosition = pos;
      });
    // ignore: empty_catches
    } catch (e) {}
    
  }

  Future<void> _setMapStyle() async {
    String stylePath = widget.isDarkMode?'assets/map_styles/dark_map.json':'assets/map_styles/light_map.json';
    final String mapStyle = await rootBundle.loadString(stylePath);
    // ignore: deprecated_member_use
    mapController?.setMapStyle(mapStyle);
  }

  void _createMarkers() {
  markers = gasStations.map((station) {
    return Marker(
      markerId: MarkerId(station.id),
      position: LatLng(station.latitude, station.longitude),
      infoWindow: InfoWindow(
        title: station.name,
        snippet: '\$${station.price.toStringAsFixed(2)}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }).toSet();

  if (mounted) setState(() {});
}

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
    setState(() => isMapReady = true);
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

  

  @override void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.isDarkMode != widget.isDarkMode){
      _setMapStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final LatLng center = LatLng(_userPosition!.latitude, _userPosition!.longitude);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: center,
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
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 0.8,
              snap: true,
              snapSizes: const [0.12, 0.5, 0.8],
              builder: (context, scrollController) {
                return StreamBuilder(
                  stream: firestoreService.getGasInfo(),
                  builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stationList = snapshot.data!.docs.map((doc) => GasStation.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
                  final nearbyStations = stationList.map((station) {
                  final distance = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, station.latitude, station.longitude) * 0.000621371;
                  return {'station': station, 'distance' : distance};
                }).where((entry) => (entry['distance'] as double) <= 25)
                .toList();

                nearbyStations.sort(
                  (a,b) => (a['distance'] as double).compareTo(b['distance'] as double),
                );

                return Container(
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: const [
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
                                            '${nearbyStations.length} stations',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
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
                          itemCount: nearbyStations.length,
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                          final station = nearbyStations[index]['station'] as GasStation;
                          final distance = nearbyStations[index]['distance'] as double;
                          return GasStationCard(
                            station: station,
                            distance: distance,
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
            );
              }
            )
        ]
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

class GasStationCard extends StatelessWidget {
  final GasStation station;
  final double distance;
  final VoidCallback onTap;

  const GasStationCard({
    super.key,
    required this.station,
    required this.distance,
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
                          '${distance.toStringAsFixed(1)} mi',
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
                  
                  Text(
                    '\$${station.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


