import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/marker/add_images_widget.dart';
import 'package:insignio_frontend/marker/marker_page.dart';
import 'package:insignio_frontend/networking/data/map_marker.dart';
import 'package:insignio_frontend/networking/data/marker_type.dart';
import 'package:insignio_frontend/networking/extractor.dart';

import '../auth/authentication.dart';
import '../map/location_provider.dart';
import '../util/pair.dart';

class ReportPage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = "/reportPage";

  ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with GetItStateMixin<ReportPage> {
  List<Pair<Uint8List, String?>> images = [];
  MarkerType? markerType;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
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
            AddImagesWidget(
              images,
              loading ? null : (image) => setState(() => images.add(image)),
              loading ? null : (index) => setState(() => images.removeAt(index)),
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
              onChanged: loading
                  ? null
                  : (MarkerType? newMarkerType) => setState(() => markerType = newMarkerType),
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
            if (loading)
              const CircularProgressIndicator()
            else
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

  void send() async {
    var pos = get<LocationProvider>().lastLocationInfo().position;
    var cookie = get<Authentication>().maybeCookie();
    var mt = markerType;
    if (pos == null || cookie == null || images.isEmpty || mt == null || mt == MarkerType.unknown) {
      return; // this should be unreachable, since "Send" should be hidden
    }

    setState(() {
      loading = true;
      error = null;
    });

    addMarker(pos.latitude, pos.longitude, mt, cookie).then(
      (markerId) {
        var mapMarker = MapMarker(markerId, pos.latitude, pos.longitude, mt);
        Future.wait(images.map((e) => addMarkerImage(markerId, e.first, e.second, cookie))).then(
          (_) {
            Navigator.popAndPushNamed(
              context,
              MarkerPage.routeName,
              arguments: MarkerPageArgs(mapMarker),
              result: mapMarker,
            );
          },
          onError: (e) {
            Navigator.popAndPushNamed(
              context,
              MarkerPage.routeName,
              arguments: MarkerPageArgs(mapMarker, errorAddingImage: e.toString()),
              result: mapMarker,
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
