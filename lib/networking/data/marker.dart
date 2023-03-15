import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';

class Marker extends MapMarker {
  final DateTime creationDate;
  final DateTime? resolutionDate;
  final int createdBy;
  final bool canBeReported;

  Marker(int id, double latitude, double longitude, MarkerType type, this.creationDate,
      this.resolutionDate, this.createdBy, this.canBeReported)
      : super(id, latitude, longitude, type, resolutionDate != null);
}
