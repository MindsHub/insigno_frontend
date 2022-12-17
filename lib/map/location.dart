import 'package:geolocator/geolocator.dart';
class CustomLocation{
  static Position? position;
  static bool init = false;
  CustomLocation(){
    if(!init) {
      startListeningForLocation();
    }

  }
  Position? getPosition(){
    return position;
  }
  void startListeningForLocation() async {
    init=true;
    var value = await Geolocator.requestPermission();
    if (value == LocationPermission.always ||
        value == LocationPermission.whileInUse) {
      if (await Geolocator.isLocationServiceEnabled()) {
        Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 1))
            .listen((Position pos) {
              position = pos;
        });
      } else {
        Geolocator.openLocationSettings();
      }
    }
  }
}