import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../networking/const.dart';
import 'location.dart';
import 'map_marker.dart';
import '../marker/marker_page.dart';
import '../marker/marker_type.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  static final LatLng initialCoordinates = LatLng(45.75548, 11.00323);

  final Distance distance = const Distance();
  final MapController mapController = MapController();
  LatLng? lastLoadMarkersPos;

  Position? position;
  List<MapMarker> markers = [];

  MapWidgetState() {
    mapController.mapEventStream
        .where((event) => event.zoom >= 15.0 && (lastLoadMarkersPos == null
              || distance.distance(lastLoadMarkersPos!, event.center) > 5000))
        .forEach((event) {
          lastLoadMarkersPos = event.center;
          loadMarkers(event.center);
        });

    mapController.mapEventStream
        .where((event) => event.zoom < 15.0)
        .forEach((element) {
          lastLoadMarkersPos = null;
          setState(() { markers = []; });
        });

    loadMarkers(initialCoordinates);
  }

  void moveCenter() {
    setState(() {
      position = CustomLocation().getPosition();
    });
    if (position != null) {
      mapController.move(
          LatLng(position!.latitude, position!.longitude), 18.45);
    }
  }

  void loadMarkers(final LatLng latLng) async {
    final response = await http.get(Uri.parse(
        "$insignio_server/map/get_near?y=${latLng.latitude}&x=${latLng.longitude}"));

    if (response.statusCode == 200) {
      var array = List.from(jsonDecode(response.body));
      List<MapMarker> newMarkers = <MapMarker>[];
      for (var cur in array) {
        var point = cur["point"];
        newMarkers.add(MapMarker(0, point['y'] as double, point['x'] as double,
            MarkerType.values.first));
      }
      setState(() {
        markers = newMarkers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: initialCoordinates,
        zoom: 15.0,
        maxZoom: 18.45, // OSM supports at most the zoom value 19
      ),
      nonRotatedChildren: [
        AttributionWidget(attributionBuilder: (_) {
          return const Text("© OpenStreetMap contributors");
        })
      ],
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: (position == null
              ? <Marker>[]
              : [
            Marker(
              width: 30.0,
              height: 30.0,
              point: LatLng(position!.latitude, position!.longitude),
              builder: (ctx) =>
                  SvgPicture.asset(
                      "assets/icons/current_location.svg"),
            ),
          ]) +
              markers
                  .map((e) =>
                  Marker(
                    point: LatLng(e.latitude, e.longitude),
                    builder: (ctx) =>
                        IconButton(
                          icon: Icon(e.type.icon, color: e.type.color),
                          onPressed: () =>
                              Navigator.pushNamed(
                                  context,
                                  MarkerWidget.routeName,
                                  arguments: MarkerWidgetArgs(e)
                              ),
                        ),
                  ))
                  .toList(),
        ),
      ],
    );
  }
}
