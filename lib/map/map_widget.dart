import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/di/setup.dart';
import 'package:insignio_frontend/networking/extractor.dart';
import 'package:latlong2/latlong.dart';

import 'location.dart';
import '../networking/data/map_marker.dart';
import '../old/marker/marker_page.dart';

class MapWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  MapWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with GetItStateMixin<MapWidget> {
  static final LatLng initialCoordinates = LatLng(45.75548, 11.00323);

  final Distance distance = const Distance();
  final MapController mapController = MapController();
  LatLng? lastLoadMarkersPos;

  List<MapMarker> markers = [];

  _MapWidgetState() {
    mapController.mapEventStream
        .where((event) =>
            event.zoom >= 15.0 &&
            (lastLoadMarkersPos == null ||
                distance.distance(lastLoadMarkersPos!, event.center) > 5000))
        .forEach((event) {
      lastLoadMarkersPos = event.center;
      loadMarkers(event.center);
    });

    mapController.mapEventStream.where((event) => event.zoom < 15.0).forEach((element) {
      lastLoadMarkersPos = null;
      setState(() {
        markers = [];
      });
    });

    loadMarkers(initialCoordinates);
  }

  void loadMarkers(final LatLng latLng) async {
    loadMapMarkers(latLng.latitude, latLng.longitude)
        .then((value) => setState(() => markers = value));
  }

  List<Marker> getMarkers(final Position? position) {
    return [position]
        .whereType<Position>()
        .map((pos) => Marker(
              width: 30.0,
              height: 30.0,
              point: LatLng(pos.latitude, pos.longitude),
              builder: (ctx) => SvgPicture.asset("assets/icons/current_location.svg"),
            ))
        .followedBy(markers.map((e) => Marker(
              point: LatLng(e.latitude, e.longitude),
              builder: (ctx) => IconButton(
                icon: Icon(e.type.icon, color: e.type.color),
                onPressed: () => Navigator.pushNamed(context, MarkerWidget.routeName,
                    arguments: MarkerWidgetArgs(e)),
              ),
            )))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            getIt<LocationProvider>().lastLocationInfo())
        .data
        ?.position;

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
        MarkerLayer(markers: getMarkers(position)),
      ],
    );
  }
}
