import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insignio_frontend/map/marker_type.dart';
import 'package:latlong2/latlong.dart';

import '../networking/const.dart';
import 'marker.dart';
import 'package:http/http.dart' as http;

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final MapController mapController = MapController();

  Position? position;
  List<MapMarker> markers = List.empty();

  void setPosition(Position? position) {
    setState(() {
      this.position = position;
    });
  }

  void loadMarkers() async {
    final response = await http.get(Uri.parse(insigno_server+'/map/getNearMarkers/'+position!.latitude.toString()+'_'+position!.longitude.toString()));

    if (response.statusCode == 200) {
      var array = List.from(jsonDecode(response.body));
       List<MapMarker> newMarkers = <MapMarker>[];
       for(var cur in array){
          newMarkers.add(MapMarker(0, cur['y'] as double, cur['x'] as double, MarkerType.values.byName(cur['type'] as String)));
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
        center: LatLng(45.75548, 11.00323),
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
                        builder: (ctx) => SvgPicture.asset(
                            "assets/icons/current_location.svg"),
                      ),
                    ]) +
              markers
                  .map((e) => Marker(
                        point: LatLng(e.latitude, e.longitude),
                        builder: (ctx) => IconButton(
                          icon: Icon(e.type.icon, color: e.type.color),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => Details(
                              title: e.type.name,
                              content: "some garbage description",
                              icon: Icon(e.type.icon, color: e.type.color),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
        ),
      ],
    );
  }
}

class Details extends StatelessWidget {
  final String title;
  final String content;
  final Icon icon;

  const Details({
    required this.title,
    required this.content,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Text(
            title,
            //style: Theme.of(context).textTheme.title,
          ),
        ],
      ),
      actions: [
        MaterialButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: Text(
        content,
        //style: Theme.of(context).textTheme.body1,
      ),
      backgroundColor: Colors.cyanAccent,
    );
  }
}
