import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'map.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<MapWidgetState> mapState = GlobalKey<MapWidgetState>();

  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: MapWidget(key: mapState),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.explore),
        onPressed: () async {
          mapState.currentState?.mapController.rotate(0);
          Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.high, distanceFilter: 1))
              .listen((Position position) {
            mapState.currentState?.setPosition(position);
          });
        },
      ),
    );
  }
}