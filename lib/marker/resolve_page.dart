import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/util/error_messages.dart';
import 'package:insigno_frontend/util/nullable.dart';
import 'package:latlong2/latlong.dart';

import '../map/location_provider.dart';
import '../networking/authentication.dart';
import '../networking/backend.dart';
import '../networking/data/map_marker.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final marker = widget.mapMarker;
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;
    final isLoggedIn = watchStream(
            (Authentication authentication) => authentication.getIsLoggedInStream(),
            get<Authentication>().isLoggedIn())
        .data;

    final errorMessage = getErrorMessage(
      l10n,
      isLoggedIn,
      position,
      whilePositionLoading: () => images.isEmpty ? l10n.addImage : null,
      afterPositionLoaded: () => (position?.position?.map(marker.isNearEnoughToResolve) ?? false)
          ? l10n.tooFarToResolve
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.resolve),
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
            if (errorMessage != null) Text(errorMessage),
            if (loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: errorMessage == null ? resolve : null,
                child: Text(l10n.resolve),
              ),
            if (error != null) Text(l10n.errorResolving(error!)),
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

    final backend = get<Backend>();
    backend.resolveMarker(widget.mapMarker.id, cookie).then(
      (_) {
        Future.wait(images.map((e) => backend.addMarkerImage(markerId, e.first, e.second, cookie)))
            .then(
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
