import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  final bool isDarkMode;

  const MapScreen({super.key, required this.isDarkMode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  // Example coordinate (LSU campus)
  final LatLng _center = const LatLng(30.4133, -91.1823);

  Future<void> _setMapStyle() async {
    String stylePath = widget.isDarkMode
        ? 'assets/map_styles/dark_map.json'
        : 'assets/map_styles/light_map.json';

    final String mapStyle = await rootBundle.loadString(stylePath);
    mapController.setMapStyle(mapStyle);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle(); // set style immediately on creation
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _setMapStyle(); // update style when theme changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
      ),
    );
  }
}