import 'package:insigno_frontend/networking/data/map_marker.dart';

/// will hold more information than MapMarker
class Marker extends MapMarker {
  final bool canBeReported;

  Marker(super.id, super.latitude, super.longitude, super.type, super.creationDate,
      super.resolutionDate, super.createdBy, super.resolvedBy, this.canBeReported);
}
