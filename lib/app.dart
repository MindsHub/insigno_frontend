import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/di/location.dart';

class InsignioApp extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    final currentPosition =
        watchStream((LocationProvider location) => location.getPositionStream(), OptionalPosition(null));

    return MaterialApp(
      title: "Insignio",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: Text(currentPosition.data?.p?.toString() ?? "No position")
        )
      )
    );
  }
}
