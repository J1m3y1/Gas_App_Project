import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:gas_app_project/secrets.dart';


class GasStationServices {
  final CollectionReference gasstation = FirebaseFirestore.instance.collection("Station_Info");
  String get apiKey => API_KEY;

  // Create: add price to non existing gas station
  Future<void> addStationFromAPI(Map<String,dynamic> station) async{
    final docRef = gasstation.doc(station['place_id']);

    return docRef.set({
      'name': station['name'],
      'address': station['vicinity'],
      'latitude': station['geometry']['location']['lat'],
      'longitude': station['geometry']['location']['lng'],
      'price': 0.0, // initial price
      'timestamp': Timestamp.now(), 
  }, SetOptions(merge: true));
    }
  
  Stream<QuerySnapshot> getGasInfo() {
    return gasstation.snapshots();
  }
  
  // Update: update gas price for existing gas station
  Future<void> updatePrice(String placeId, double newPrice){
    return gasstation.doc(placeId).update({
      'price': newPrice,
      'timestamp': Timestamp.now(),
    });
  }

  Future<List<dynamic>> fetchStations(
    double latitude, double longitude, {int radius = 50000}) async {
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$latitude,$longitude'
      '&radius=$radius'
      '&type=gas_station'
      '&key=$apiKey'
    );
      
      final response = await http.get(url);

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        final stations = data['results'] as List<dynamic>;
        return stations;
      } else{
        throw Exception('Failed to fetch stations:${response.statusCode}');
      }
    }
}