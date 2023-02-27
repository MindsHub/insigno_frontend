import 'package:http/http.dart' as http;
import 'package:insignio_frontend/networking/data/pill.dart';
import 'package:insignio_frontend/util/future.dart';

import 'const.dart';
import 'data/map_marker.dart';
import 'data/marker_type.dart';

Future<Pill> loadRandomPill() async {
  return http.get(Uri.parse("$insignioServer/pills/random")).mapParseJson().map<Pill>(
      (pill) => Pill(pill['id'], pill['text'], pill['author'], pill['source'], pill['accepted']));
}

Future<List<MapMarker>> loadMapMarkers(final double latitude, final double longitude) async {
  return http
      .get(Uri.parse("$insignioServer/map/get_near?y=$latitude&x=$longitude"))
      .mapParseJson()
      .map((markers) => markers.map<MapMarker>((marker) {
            var point = marker["point"];
            return MapMarker(
                0, point['y'] as double, point['x'] as double, MarkerType.values.first);
          }).toList());
}
