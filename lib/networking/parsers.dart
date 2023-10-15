import 'package:collection/collection.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';
import 'package:insigno_frontend/networking/data/image_verification.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker.dart';
import 'package:insigno_frontend/networking/data/marker_image.dart';
import "package:insigno_frontend/util/nullable.dart";

import 'data/marker_type.dart';
import 'data/marker_update.dart';
import 'data/pill.dart';
import 'data/user.dart';

User userFromJson(dynamic u) {
  return User(u["id"], u["name"], u["points"]);
}

AuthenticatedUser authenticatedUserFromJson(dynamic u) {
  return AuthenticatedUser(
      u["id"], u["name"], u["points"], u["is_admin"], u["email"], u["accepted_to_review"]);
}

List<int> intListFromJson(dynamic l) {
  return (l as List<dynamic>).map<int>((i) => i as int).toList();
}

List<String> stringListFromJson(dynamic l) {
  return (l as List<dynamic>).map<String>((i) => i as String).toList();
}

MarkerType markerTypeFromJson(dynamic m) {
  return MarkerType.values.firstWhereOrNull((type) => type.id == m["marker_types_id"]) ??
      MarkerType.unknown;
}

MapMarker mapMarkerFromJson(dynamic m) {
  var point = m["point"];
  var resolutionDate = m["resolution_date"];
  return MapMarker(
    m["id"],
    point["y"] as double,
    point["x"] as double,
    markerTypeFromJson(m),
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
    markerTypeFromJson(m),
    DateTime.parse(m["creation_date"]),
    (resolutionDate as String?).map(DateTime.parse), // might be null
    userFromJson(m["created_by"]),
    (m["solved_by"] as Map<String, dynamic>?).map(userFromJson), // might be null
    intListFromJson(m["images_id"]),
    m["can_report"],
  );
}

Pill pillFromJson(dynamic p) {
  return Pill(p["id"], p["text"], p["author"], p["source"], p["accepted"]);
}

MarkerUpdate markerUpdateFromJson(dynamic u) {
  return MarkerUpdate(u["id"], u["earned_points"]);
}

MarkerImage markerImageFromJson(dynamic u) {
  return MarkerImage(u["id"], markerTypeFromJson(u));
}

List<ImageVerification> sessionFromJson(dynamic u) {
  return (u as List<dynamic>)
      .map<ImageVerification>((e) => ImageVerification(e["image_id"], e["marker_id"], e["verdict"],
          markerTypeFromJson(e), intListFromJson(e["all_marker_images"])))
      .toList();
}
