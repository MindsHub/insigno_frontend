import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insignio_frontend/marker/marker_page.dart';
import 'package:insignio_frontend/marker/marker_type.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/transformers.dart';

import '../networking/const.dart';
import 'location.dart';
import 'map_marker.dart';
import 'package:http/http.dart' as http;

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
        "$insigno_server/map/getNearMarkers/${latLng.latitude}_${latLng.longitude}"));

    if (response.statusCode == 200) {
      var array = List.from(jsonDecode(response.body));
      List<MapMarker> newMarkers = <MapMarker>[];
      for (var cur in array) {
        newMarkers.add(MapMarker(0, cur['y'] as double, cur['x'] as double,
            MarkerType.values.byName(cur['type'] as String)));
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
