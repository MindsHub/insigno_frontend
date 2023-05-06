import 'package:collection/collection.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker.dart';
import "package:insigno_frontend/util/nullable.dart";

import 'data/marker_type.dart';
import 'data/marker_update.dart';
import 'data/pill.dart';
import 'data/user.dart';

User userFromJson(dynamic u) {
  return User(u["id"], u["name"], u["points"]);
}

AuthenticatedUser authenticatedUserFromJson(dynamic u) {
  return AuthenticatedUser(u["id"], u["name"], u["points"], u["is_admin"]);
}

List<int> imageListFromJson(dynamic l) {
  return (l as List<dynamic>).map<int>((i) => i as int).toList();
}

MapMarker mapMarkerFromJson(dynamic m) {
  var point = m["point"];
  var resolutionDate = m["resolution_date"];
  return MapMarker(
    m["id"],
    point["y"] as double,
    point["x"] as double,
    MarkerType.values.firstWhereOrNull((type) => type.id == m["marker_types_id"]) ??
        MarkerType.unknown,
    DateTime.parse(m["creation_date"]),
    (resolutionDate as String?).map(DateTime.parse), // might be null
    m["created_by"],
    m["solved_by"], // might be null
  );
}

Marker markerFromJson(dynamic m) {
  var point = m["point"];
  var resolutionDate = m["resolution_date"];
  return Marker(
    m["id"],
    point["y"] as double,
    point["x"] as double,
    MarkerType.values.firstWhereOrNull((type) => type.id == m["marker_types_id"]) ??
        MarkerType.unknown,
    DateTime.parse(m["creation_date"]),
    (resolutionDate as String?).map(DateTime.parse), // might be null
    userFromJson(m["created_by"]),
    (m["solved_by"] as Map<String, dynamic>?).map(userFromJson), // might be null
    imageListFromJson(m["images_id"]),
    m["can_report"],
  );
}

Pill pillFromJson(dynamic p) {
  return Pill(p["id"], p["text"], p["author"], p["source"], p["accepted"]);
}

MarkerUpdate markerUpdateFromJson(dynamic u) {
  return MarkerUpdate(u["id"], u["earned_points"]);
}
