import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:insigno_frontend/networking/data/user.dart';

/// holds more information than MapMarker
class Marker extends MapMarker {
  final User reportedByUser;
  final User? resolvedByUser;
  final List<int> images;
  final bool canBeReported;

  Marker(
      int id,
      double latitude,
      double longitude,
      MarkerType type,
      DateTime creationDate,
      DateTime? resolutionDate,
      this.reportedByUser,
      this.resolvedByUser,
      this.images,
      this.canBeReported)
      : super(id, latitude, longitude, type, creationDate, resolutionDate, reportedByUser.id,
            resolvedByUser?.id);
}
