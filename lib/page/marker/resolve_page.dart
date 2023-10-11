import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/provider/location_provider.dart';
import 'package:insigno_frontend/page/marker/add_images_widget.dart';
import 'package:insigno_frontend/provider/auth_user_provider.dart';
import 'package:insigno_frontend/util/error_messages.dart';
import 'package:insigno_frontend/util/error_text.dart';
import 'package:insigno_frontend/util/nullable.dart';
import 'package:insigno_frontend/util/pair.dart';
import 'package:latlong2/latlong.dart';

class ResolvePage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = '/resolvePage';

  final MapMarker mapMarker;

  ResolvePage(this.mapMarker, {Key? key}) : super(key: key);

  @override
  State<ResolvePage> createState() => _ResolvePageState();
}

class ResolvedResult {
  final String? errorAddingImages;

  ResolvedResult(this.errorAddingImages);
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
      isLoggedIn,
      position,
      whilePositionLoading: () => images.isEmpty ? ErrorMessage.addImage : null,
      afterPositionLoaded: () => (position?.position?.map(marker.isNearEnoughToResolve) ?? false)
          ? null
          : ErrorMessage.tooFarToResolve,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.resolve),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AddImagesWidget(
                images,
                loading ? null : (image) => setState(() => images.add(image)),
                loading ? null : (index) => setState(() => images.removeAt(index)),
              ),
              const SizedBox(
                height: 12,
                width: double.infinity, // to make the column have maximum width
              ),
              if (errorMessage != null) Text(errorMessage.toLocalizedString(l10n)),
              if (loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: errorMessage == null ? resolve : null,
                  child: Text(l10n.resolve),
                ),
              ErrorText(error, l10n.errorResolving),
            ],
          ),
        ),
      ),
    );
  }

  void resolve() {
    var markerId = widget.mapMarker.id;
    if (images.isEmpty) {
      return; // should be unreachable
    }

    setState(() {
      loading = true;
      error = null;
    });

    final backend = get<Backend>();
    backend.resolveMarker(widget.mapMarker.id).then(
      (markerUpdate) {
        get<AuthUserProvider>().addPoints(markerUpdate.earnedPoints);
        Future.wait(images.map((e) => backend.addMarkerImage(markerId, e.first, e.second))).then(
          (_) => Navigator.pop(context, ResolvedResult(null)),
          onError: (e) => Navigator.pop(context, ResolvedResult(e.toString())),
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
