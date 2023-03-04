import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/marker/marker_page.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';
import 'package:insignio_frontend/networking/data/marker_type.dart';
import 'package:insignio_frontend/networking/extractor.dart';
import "package:os_detect/os_detect.dart" as platform;
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
  Uint8List? image;
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
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (image == null)
                const Icon(Icons.image, size: 128)
              else
                ClipRRect(
                  child: Image.memory(
                    image!,
                    height: 128,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (platform.isAndroid || platform.isIOS)
                    ElevatedButton(child: const Text("Shoot"), onPressed: pickImage),
                ],
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
                onChanged: (MarkerType? newMarkerType) =>
                    setState(() => markerType = newMarkerType),
                value: markerType,
              ),
              const SizedBox(height: 12),
              if (!isLoggedIn)
                const Text("You must log in in order to report")
              else if (position?.permissionGranted == false)
                const Text("Grant permission to access location")
              else if (position?.servicesEnabled == false)
                const Text("Enable location services")
              else if (image == null)
                const Text("Select an image")
              else if (markerType == null)
                const Text("Select a marker type")
              else if (position?.position == null)
                const Text("Location is loading, please wait..."),
              ElevatedButton(
                child: const Text("Send"),
                onPressed: (!isLoggedIn ||
                        image == null ||
                        markerType == null ||
                        position?.position == null)
                    ? null
                    : send,
              ),
              if (error != null) Text("Error: $error"),
            ],
          ),
        ),
      ),
    );
  }

  void pickImage() async {
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
          image = value.second;
        });
      }
    });
  }

  void send() async {
    var pos = getIt<LocationProvider>().lastLocationInfo().position;
    var cookie = getIt<Authentication>().maybeCookie();
    var img = image;
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
              arguments: MarkerPageArgs(
                  MapMarker(markerId, pos.latitude, pos.longitude, marker),
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
