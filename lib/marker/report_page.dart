import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/marker/marker_page.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';
import 'package:insignio_frontend/networking/data/marker_type.dart';
import 'package:insignio_frontend/networking/extractor.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/authentication.dart';
import '../di/setup.dart';
import '../map/location.dart';
import '../util/pair.dart';

class ReportPage extends StatefulWidget with GetItStatefulWidgetMixin {
  ReportPage({super.key});

  static const routeName = "/reportPage";

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with GetItStateMixin<ReportPage> {
  List<Uint8List> images = [];
  String? imageMimeType;
  MarkerType? markerType;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            getIt<LocationProvider>().lastLocationInfo())
        .data;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                getIt<Authentication>().isLoggedIn())
            .data ??
        false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Report"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[const SizedBox(width: 16)]
                    .followedBy(images
                    .expand<Widget>((image) => [
                          ClipRRect(
                            child: Image.memory(
                              image,
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                          ),
                          const SizedBox(width: 16),
                        ]))
                    .followedBy([
                  Ink(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: InkWell(
                        onTap: captureImage,
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: SizedBox(
                          child: Icon(
                            Icons.add,
                            size: 48,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          width: 96,
                          height: 128,
                        )),
                  ),
                  const SizedBox(width: 16),
                ]).toList(growable: false),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton(
              hint: const Text("Choose a marker type"),
              items: MarkerType.values
                  .where((element) => element != MarkerType.unknown)
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Row(children: [
                        e.getThemedIcon(context),
                        const SizedBox(width: 12),
                        Text(e.name)
                      ])))
                  .toList(growable: false),
              onChanged: (MarkerType? newMarkerType) => setState(() => markerType = newMarkerType),
              value: markerType,
            ),
            const SizedBox(height: 12),
            if (!isLoggedIn)
              const Text("You must log in in order to report")
            else if (position?.permissionGranted == false)
              const Text("Grant permission to access location")
            else if (position?.servicesEnabled == false)
              const Text("Enable location services")
            else if (images.isEmpty)
              const Text("Select an image")
            else if (markerType == null)
              const Text("Select a marker type")
            else if (position?.position == null)
              const Text("Location is loading, please wait..."),
            ElevatedButton(
              child: const Text("Send"),
              onPressed: (!isLoggedIn ||
                      images.isEmpty ||
                      markerType == null ||
                      position?.position == null)
                  ? null
                  : send,
            ),
            if (error != null) Text("Error: $error"),
          ],
        ),
      ),
    );
  }

  void captureImage() async {
    await ImagePicker().pickImage(source: ImageSource.camera).then((value) async {
      if (value != null) {
        return Pair(value.mimeType, await File(value.path).readAsBytes());
      } else {
        return null;
      }
    }).then((value) {
      if (value != null) {
        setState(() {
          imageMimeType = value.first;
          images.add(value.second);
        });
      }
    });
  }

  void send() async {
    var pos = getIt<LocationProvider>().lastLocationInfo().position;
    var cookie = getIt<Authentication>().maybeCookie();
    var img = images[0];
    var mime = imageMimeType;
    var marker = markerType;
    if (pos == null ||
        cookie == null ||
        img == null ||
        marker == null ||
        marker == MarkerType.unknown) {
      return; // this should be unreachable, since "Send" should be hidden
    }

    setState(() {
      loading = true;
      error = null;
    });

    addMarker(pos.latitude, pos.longitude, marker, cookie).then(
      (markerId) {
        addMarkerImage(markerId, img, mime, cookie).then(
          (_) {
            Navigator.popAndPushNamed(
              context,
              MarkerPage.routeName,
              arguments: MarkerPageArgs(MapMarker(markerId, pos.latitude, pos.longitude, marker)),
            );
          },
          onError: (e) {
            Navigator.popAndPushNamed(
              context,
              MarkerPage.routeName,
              arguments: MarkerPageArgs(MapMarker(markerId, pos.latitude, pos.longitude, marker),
                  errorAddingImage: e.toString()),
            );
          },
        );
      },
      onError: (e) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      },
    );
  }
}
