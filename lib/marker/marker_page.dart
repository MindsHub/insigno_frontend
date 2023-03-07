import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/marker/resolve_page.dart';
import 'package:insignio_frontend/networking/const.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';
import 'package:insignio_frontend/networking/data/marker.dart';
import 'package:insignio_frontend/networking/extractor.dart';
import 'package:insignio_frontend/util/iterable.dart';

import '../auth/authentication.dart';
import '../di/setup.dart';

class MarkerPage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = '/markerWidget';

  final MapMarker mapMarker;
  final String errorAddingImage;

  MarkerPage(MarkerPageArgs args, {super.key})
      : mapMarker = args.mapMarker,
        errorAddingImage = args.errorAddingImage;

  @override
  State<MarkerPage> createState() => _MarkerPageState();
}

class MarkerPageArgs {
  final MapMarker mapMarker;
  final String errorAddingImage;

  MarkerPageArgs(this.mapMarker, {this.errorAddingImage = ""});
}

class _MarkerPageState extends State<MarkerPage> with GetItStateMixin<MarkerPage> {
  List<int>? images;
  Marker? marker;

  @override
  void initState() {
    super.initState();
    getImagesForMarker(widget.mapMarker.id).then((value) => setState(() => images = value));
    getMarker(widget.mapMarker.id).then((value) => setState(() => marker = value));
  }

  @override
  Widget build(BuildContext context) {
    final MapMarker mapMarker = (marker ?? widget.mapMarker);
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                getIt<Authentication>().isLoggedIn())
            .data ??
        false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(children: [
          Text(mapMarker.type.name + " marker"),
          const SizedBox(width: 12),
          mapMarker.type.getThemedIcon(context)
        ]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (images?.isNotEmpty == true)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: images!
                      .expandIndexed(
                        (index, image) => [
                          if (index == 0) const SizedBox(width: 16),
                          ClipRRect(
                            child: Image.network(
                              "$insignioServer/map/image/$image",
                              height: 128,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                          ),
                          const SizedBox(width: 16),
                        ],
                      )
                      .toList(growable: false),
                ),
              )
            else if (images == null)
              const SizedBox(
                height: 128,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (widget.errorAddingImage.isNotEmpty) const SizedBox(height: 16),
            if (widget.errorAddingImage.isNotEmpty)
              Text("An error occured when uploading the image: ${widget.errorAddingImage}"),
            const SizedBox(height: 16),
            if (marker == null)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                child: Text(marker?.resolutionDate == null
                    ? (isLoggedIn ? "Resolve" : "Log in to resolve")
                    : "Already solved"),
                onPressed: (marker?.resolutionDate == null && isLoggedIn)
                    ? () => Navigator.pushNamed(context, ResolvePage.routeName, arguments: marker!)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
