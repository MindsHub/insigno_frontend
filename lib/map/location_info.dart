import 'package:geolocator/geolocator.dart';
import 'package:insigno_frontend/util/position.dart';
import 'package:latlong2/latlong.dart';

class LocationInfo {
  Position? position;
  bool servicesEnabled;
  bool permissionGranted;

  LocationInfo(this.position, this.servicesEnabled, this.permissionGranted);

  LatLng? toLatLng() {
    return position?.toLatLng();
  }
}
