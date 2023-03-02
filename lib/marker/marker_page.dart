import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';

class MarkerPage extends StatefulWidget {
  const MarkerPage({super.key});

  static const routeName = '/markerWidget';

  @override
  State<MarkerPage> createState() => _MarkerPageState();
}

class MarkerPageArgs {
  final MapMarker mapMarker;
  final String errorAddingImage;

  MarkerPageArgs(this.mapMarker, {this.errorAddingImage = ""});
}

class _MarkerPageState extends State<MarkerPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)!
        .settings
        .arguments as MarkerPageArgs;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(children: [
          Text(args.mapMarker.type.name + " marker"),
          const SizedBox(width: 12),
          args.mapMarker.type.getThemedIcon(context)
        ]),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TODO map widget
              if (args.errorAddingImage.isNotEmpty)
                Text("An error occured when uploading the image: ${args.errorAddingImage}")
            ],
          )),
    );
  }
}