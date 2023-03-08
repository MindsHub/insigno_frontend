import 'package:geolocator/geolocator.dart';

import 'marker_type.dart';
import 'package:latlong2/latlong.dart';

class MapMarker {
  final int id;
  final double latitude;
  final double longitude;
  final MarkerType type;

  MapMarker(this.id, this.latitude, this.longitude, this.type);

  LatLng getLatLng() {
    return LatLng(latitude, longitude);
  }

  bool isNearEnoughToResolve(Position pos) {
    return Geolocator.distanceBetween(pos.latitude, pos.longitude, latitude, longitude) < 50; // m
  }
}
