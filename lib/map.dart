import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final MapController mapController = MapController();

  Position? position;

  void setPosition(Position? position) {
    setState(() {
      this.position = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(45.75548, 11.00323),
        zoom: 15.0,
        maxZoom: 18.45, // OSM supports at most the zoom value 19
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return const Text("© OpenStreetMap contributors");
          },
        ),
        MarkerLayerOptions(
          markers: position == null ? [
          ] : [
            Marker(
              width: 30.0,
              height: 30.0,
              point: LatLng(position!.latitude, position!.longitude),
              builder: (ctx) => SvgPicture.asset(
                  "assets/icons/current_location.svg"
              ),
            ),
          ],
        ),
      ],
    );
  }
}