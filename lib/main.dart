import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'loading.dart';
import 'map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;

  endLoading() => setState(() {
        loading = false;
      });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Insignio",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loading
          ? Scaffold(body: LoadingScreen(callback: endLoading))
          : MyHomePage(title: "Insignio"),
    );
  }
}

class MyHomePage extends StatelessWidget {
  double rotation = 0.0;
  final GlobalKey<MapWidgetState> mapState = GlobalKey<MapWidgetState>();

  MyHomePage({Key? key, required this.title}) : super(key: key);

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
