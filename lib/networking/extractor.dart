import 'dart:convert';

import 'package:http/http.dart' as http;

import 'const.dart';
import 'data/map_marker.dart';
import 'data/marker_type.dart';

Future<List<MapMarker>> loadMapMarkers(final double latitude, final double longitude) async {
  final response = await http.get(Uri.parse(
      "$insignioServer/map/get_near?y=$latitude&x=$longitude"));

  return List.from(jsonDecode(response.body))
    .map((marker) {
      var point = marker["point"];
      return MapMarker(0, point['y'] as double, point['x'] as double, MarkerType.values.first);
  }).toList(growable: false);
}