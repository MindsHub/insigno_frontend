import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:insignio_frontend/networking/data/pill.dart';
import 'package:insignio_frontend/networking/error.dart';
import 'package:insignio_frontend/util/future.dart';
import 'package:collection/collection.dart';

import 'const.dart';
import 'data/map_marker.dart';
import 'data/marker_type.dart';

// TODO use a Client to make multiple requests to the same server

Future<Pill> loadRandomPill() async {
  return http.get(Uri.parse("$insignioServer/pills/random")).mapParseJson().map<Pill>(
      (pill) => Pill(pill['id'], pill['text'], pill['author'], pill['source'], pill['accepted']));
}

Future<List<MapMarker>> loadMapMarkers(final double latitude, final double longitude) async {
  return http
      .get(Uri.parse("$insignioServer/map/get_near?y=$latitude&x=$longitude"))
      .throwErrors()
      .mapParseJson()
      .map((markers) => markers.map<MapMarker>((marker) {
            var point = marker["point"];
            return MapMarker(
              marker["id"],
              point["y"] as double,
              point["x"] as double,
              MarkerType.values.firstWhereOrNull((type) => type.id == marker["marker_types_id"]) ??
                  MarkerType.unknown,
            );
          }).toList());
}

Future<String> addMarker(
    double latitude, double longitude, MarkerType markerType, String cookie) async {
  var request = http.MultipartRequest("POST", Uri.parse(insignioServer + "/map/add"));
  request.headers["Cookie"] = cookie;
  request.fields["y"] = latitude.toString();
  request.fields["x"] = longitude.toString();
  request.fields["marker_types_id"] = markerType.id.toString();

  var response = await request.send().throwErrors();
  return await response.stream.bytesToString();
}

Future<void> addMarkerImage(
    String markerId, Uint8List image, String? mimeType, String cookie) async {
  mimeType = null;

  var request = http.MultipartRequest("POST", Uri.parse(insignioServer + "/map/image/add"));
  request.headers["Cookie"] = cookie;
  request.fields["refers_to_id"] = markerId;

  request.files.add(http.MultipartFile.fromBytes(
    "image",
    image,
    contentType: mimeType == null ? MediaType("image", "") : MediaType.parse(mimeType),
  ));

  await request.send().throwErrors();
}
