import 'package:geolocator/geolocator.dart';

class LocationService{
    static final LocationService _instance = LocationService._internal();
    factory LocationService() => _instance;
    LocationService._internal();

    Position? _currentPosition;

    Future<Position> getCurrentLocation() async {
      bool serviceEnabled;
      LocationPermission premission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(!serviceEnabled){
        throw Exception('Location services are disabled.');
      }


      premission = await Geolocator.checkPermission();
      if(premission == LocationPermission.denied){
        premission = await Geolocator.requestPermission();
        if(premission == LocationPermission.denied){
          throw Exception('Location premissions are denied.');
        }
      }

      if(premission == LocationPermission.deniedForever){
        throw Exception('Location Premissions are permanently denied');
      }

      // ignore: deprecated_member_use
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      return _currentPosition!;
    }
  }