import 'package:geolocator/geolocator.dart';

class LocationInfo {
  Position? position;
  bool servicesEnabled;
  bool permissionGranted;

  LocationInfo(this.position, this.servicesEnabled, this.permissionGranted);
  
  static LocationInfo initial() {
    return LocationInfo(null, true, true);
  }
}