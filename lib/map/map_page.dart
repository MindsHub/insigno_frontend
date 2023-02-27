import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/map/map_widget.dart';

class MapPage extends StatelessWidget with GetItMixin {
  MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          Text("Insignio"),
          Text("Pill", style: TextStyle(fontSize: 14.0, color: Colors.white70))
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
      body: MapWidget(),
    );
  }
}
