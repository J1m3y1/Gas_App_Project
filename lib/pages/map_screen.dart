import 'package:flutter/material.dart';
import 'package:gas_app_project_dev/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  final bool isDarkMode;
  const MapScreen({super.key, required this.isDarkMode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    getUserLocation();
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
    mapController?.setMapStyle(mapStyle);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
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
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
