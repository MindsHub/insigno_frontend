import 'package:flutter/material.dart';
import 'package:insignio_frontend/networking/const.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';
import 'package:insignio_frontend/networking/extractor.dart';

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
  List<int>? images;

  @override
  void initState() {
    super.initState();
    getImagesForMarker(widget.mapMarker.id).then((value) => setState(() => images = value));
  }

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
              if (images?.isNotEmpty == true)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: images!
                        .map(
                          (image) => ClipRRect(
                            child: Image.network(
                              "$insignioServer/map/image/$image",
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                          ),
                        )
                        .toList(growable: false),
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