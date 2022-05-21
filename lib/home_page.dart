import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'login.dart';
import 'map.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<MapWidgetState> mapState = GlobalKey<MapWidgetState>();

  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  void startListeningForLocation() async {
    var value = await Geolocator.requestPermission();
    if (value == LocationPermission.always ||
        value == LocationPermission.whileInUse) {
      if (await Geolocator.isLocationServiceEnabled()) {
        Geolocator.getPositionStream(
                locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.high, distanceFilter: 1))
            .listen((Position position) {
          mapState.currentState?.setPosition(position);
        });
      } else {
        Geolocator.openLocationSettings();
      }
    }
  }

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
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
            ),
          ],
        ),
        body: MapWidget(key: mapState),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            child: const Icon(Icons.explore),
            onPressed: () async {
              mapState.currentState?.mapController.rotate(0);
            },
          ),
          FloatingActionButton(
            child: const Icon(Icons.location_on),
            onPressed: () async {
              startListeningForLocation();
            },
          ),
        ]));
  }
}
