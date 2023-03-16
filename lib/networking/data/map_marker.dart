import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'marker_type.dart';

class MapMarker {
  final int id;
  final double latitude;
  final double longitude;
  final MarkerType type;
  final DateTime creationDate;
  final DateTime? resolutionDate;
  final int reportedBy;
  final int? resolvedBy;

  MapMarker(this.id, this.latitude, this.longitude, this.type, this.creationDate,
      this.resolutionDate, this.reportedBy, this.resolvedBy);

  LatLng getLatLng() {
    return LatLng(latitude, longitude);
  }

  bool isNearEnoughToResolve(Position pos) {
    return Geolocator.distanceBetween(pos.latitude, pos.longitude, latitude, longitude) < 50; // m
  }

  bool isResolved() {
    return resolutionDate != null;
  }
}
