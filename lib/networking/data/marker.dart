import 'package:insigno_frontend/networking/data/map_marker.dart';

class Marker extends MapMarker {
  final DateTime creationDate;
  final DateTime? resolutionDate;
  final int createdBy;

  Marker(super.id, super.latitude, super.longitude, super.type, this.creationDate,
      this.resolutionDate, this.createdBy);
}
