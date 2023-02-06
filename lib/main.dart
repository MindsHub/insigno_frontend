import 'package:flutter/material.dart';
import 'package:insignio_frontend/marker/marker_page.dart';

import 'home_page.dart';
import 'loading_page.dart';
import 'map/location.dart';

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
  var tmp = CustomLocation();
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
          : HomePage(title: "Insignio"),
      routes: {
        MarkerWidget.routeName: (context) => const MarkerWidget()
      },
    );
  }
}
