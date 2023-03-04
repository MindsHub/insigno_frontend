import 'package:flutter/material.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';

class MarkerPage extends StatefulWidget {
  final MapMarker mapMarker;
  final String errorAddingImage;

  MarkerPage(MarkerPageArgs args, {super.key})
      : mapMarker = args.mapMarker,
        errorAddingImage = args.errorAddingImage;

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(children: [
          Text(widget.mapMarker.type.name + " marker"),
          const SizedBox(width: 12),
          widget.mapMarker.type.getThemedIcon(context)
        ]),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [],
                ),
              ),
              // TODO map widget
              if (widget.errorAddingImage.isNotEmpty)
                Text("An error occured when uploading the image: ${widget.errorAddingImage}")
            ],
          ),
        ),
      ),
    );
  }
}
