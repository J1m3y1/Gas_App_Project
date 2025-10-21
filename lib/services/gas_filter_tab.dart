import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/material.dart';


class FilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String,dynamic> currentFilters;

  const FilterSheet({required this.onApply, required this.currentFilters, Key? key}) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double maxDistance; 
  String sortOption = 'distance_asc';

  @override void initState() {
    super.initState();
    maxDistance = widget.currentFilters['maxDistance'] ?? 10;
    sortOption = widget.currentFilters['sort'] ?? 'distance_asc';
  }

  @override Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const SizedBox(height: 16,),

          Text('Max Distance: ${maxDistance.toStringAsFixed(1)} miles'),
          Slider(
            value: maxDistance,
            min: 1,
            max: 25,
            divisions: 24,
            label: '${maxDistance.toStringAsFixed(1)} mi',
            onChanged: (val) => setState(() => maxDistance = val),
          ),

          const SizedBox(height: 16,),
          const Text('Sort By:'),

          DropdownButton<String>(
            value: sortOption,
            isExpanded: true,
            items: const[
              DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High') ,),
              DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low'),),
              DropdownMenuItem(value: 'distance_asc', child: Text('Distance: Closest First'),),
              DropdownMenuItem(value: 'distance_desc', child: Text('Distance: Farthest First'),),
            ],
            onChanged: (val) => setState(() => sortOption = val!),
          ),

          const SizedBox(height: 20,),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'maxDistance': maxDistance,
                'sort': sortOption,
              });
            },
            child: const Text('Apply Filters'),
          )
        ],
      )
    );
  }
}

class StationFilter {
  double calculateDistance(double lat1, double lon1, double lat2, double lon2){
    const earthRadius = 6371; //KM

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;
    return distance;
  }
  double _degToRad(double deg) => deg * (pi / 180);
  
}


