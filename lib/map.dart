import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(45.75548, 11.00323),
        zoom: 15.0,
        maxZoom: 18.45, // OSM supports at most the zoom value 19
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 50.0,
              height: 50.0,
              point: LatLng(45.75548, 11.00323),
              builder: (ctx) => const Icon(
                Icons.ac_unit,
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}