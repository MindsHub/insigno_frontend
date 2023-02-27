import 'package:flutter/material.dart';
import 'package:insignio_frontend/map/map_page.dart';

class InsignioApp extends StatelessWidget {
  const InsignioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Insignio",
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: MapPage(),
    );
  }
}
