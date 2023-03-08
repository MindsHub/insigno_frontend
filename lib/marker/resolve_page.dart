import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/util/nullable.dart';
import 'package:insignio_frontend/util/position.dart';
import 'package:latlong2/latlong.dart';

import '../auth/authentication.dart';
import '../di/setup.dart';
import '../map/location_provider.dart';
import '../networking/data/map_marker.dart';
import '../networking/extractor.dart';
import '../util/pair.dart';
import 'add_images_widget.dart';

class ResolvePage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = '/resolvePage';

  final MapMarker mapMarker;

  ResolvePage(this.mapMarker, {Key? key}) : super(key: key);

  @override
  State<ResolvePage> createState() => _ResolvePageState();
}

class _ResolvePageState extends State<ResolvePage> with GetItStateMixin<ResolvePage> {
  List<Pair<Uint8List, String?>> images = [];
  bool loading = false;
  String? error;

  final Distance distance = const Distance();

  @override
  Widget build(BuildContext context) {
    final marker = widget.mapMarker;
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
            .data ??
        false;
    final bool isValidPosition = position?.position?.map(marker.isNearEnoughToResolve) ?? false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Resolve"),
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
            if (!isLoggedIn)
              const Text("You must log in in order to report")
            else if (position?.permissionGranted == false)
              const Text("Grant permission to access location")
            else if (position?.servicesEnabled == false)
              const Text("Enable location services")
            else if (images.isEmpty)
              const Text("Select an image")
            else if (position?.position == null)
              const Text("Location is loading, please wait...")
            else if (!isValidPosition)
              const Text("You are too far to resolve the marker"),
            if (loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                child: const Text("Resolve"),
                onPressed: (!isLoggedIn || images.isEmpty || !isValidPosition) ? null : resolve,
              ),
            if (error != null) Text("Error: $error"),
          ],
        ),
      ),
    );
  }

  void resolve() {
    var cookie = get<Authentication>().maybeCookie();
    var markerId = widget.mapMarker.id;
    if (cookie == null || images.isEmpty) {
      return; // should be unreachable
    }

    setState(() {
      loading = true;
      error = null;
    });

    resolveMarker(widget.mapMarker.id, cookie).then(
      (_) {
        Future.wait(images.map((e) => addMarkerImage(markerId, e.first, e.second, cookie))).then(
          (_) {
            Navigator.pop(context, null);
          },
          onError: (e) {
            Navigator.pop(context, e.toString());
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
