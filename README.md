# Gas-App-Project
Mobile app to track cheapest gas prices nearby

#Set-up instructions
1. Set up flutter if haven't already. https://docs.flutter.dev/get-started/quick
2. Download an android emulator to simulate a mobile app. https://developer.android.com/studio
3. Google Map and Google Places Api Key is needed for the map and stations.
    Get your key from [Google Cloud Console](https://console.cloud.google.com/).  
   - Enable the **Maps SDK for Android**.
   - Enable the **Places API**.
<br>copy paste MAPS_API_KEY= "Your Google Map API Key" under gas_station_app > android > local.properties with a google map api
<br>copy paste API_KEY= "Your Places API Key" in a file you create called secrets.dart
4.In VsCode Terminal
    -run "flutter pub get" in the project root
    -run "flutter run" while your android emulator is open
5. Emulator Setting
    -location must set to 29.9517871, -90.1796284


   
   


