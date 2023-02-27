import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'const.dart';
import 'data/map_marker.dart';
import 'data/marker_type.dart';

Future<String> loadRandomPill() async {
  return http.get(Uri.parse("$insignioServer/pills/random"))
      .asStream()
      .map<String>((response) => jsonDecode(response.body)['text'])
      .first;
}

Future<List<MapMarker>> loadMapMarkers(final double latitude, final double longitude) async {
  return http.get(Uri.parse("$insignioServer/map/get_near?y=$latitude&x=$longitude"))
    .asStream()
    .map((response) => jsonDecode(response.body))
    .flatMap<MapMarker>((markers) => Stream.fromIterable(markers).map((marker) {
      var point = marker["point"];
      return MapMarker(0, point['y'] as double, point['x'] as double, MarkerType.values.first);
    }))
    .toList();
}