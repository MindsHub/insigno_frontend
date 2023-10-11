import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:insigno_frontend/provider/location_provider.dart';
import 'package:insigno_frontend/page/marker/add_images_widget.dart';
import 'package:insigno_frontend/provider/auth_user_provider.dart';
import 'package:insigno_frontend/util/error_messages.dart';
import 'package:insigno_frontend/util/error_text.dart';
import 'package:insigno_frontend/util/pair.dart';

class ReportPage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = "/reportPage";

  ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class ReportedResult {
  final MapMarker newMapMarker;
  final String? errorAddingImages;

  ReportedResult(this.newMapMarker, this.errorAddingImages);
}

class _ReportPageState extends State<ReportPage> with GetItStateMixin<ReportPage> {
  List<Pair<Uint8List, String?>> images = [];
  MarkerType? markerType;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
      whilePositionLoading: () {
        if (images.isEmpty) {
          return ErrorMessage.addImage;
        } else if (markerType == null) {
          return ErrorMessage.selectMarkerType;
        } else {
          return null;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.report),
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
              DropdownButton(
                hint: Text(l10n.markerType),
                items: MarkerType.values
                    .where((element) => element != MarkerType.unknown)
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Row(children: [
                          e.getThemedIcon(context),
                          const SizedBox(width: 8),
                          Text(e.getName(context))
                        ])))
                    .toList(growable: false),
                onChanged: loading
                    ? null
                    : (MarkerType? newMarkerType) => setState(() => markerType = newMarkerType),
                value: markerType,
              ),
              const SizedBox(height: 12),
              if (errorMessage != null) Text(errorMessage.toLocalizedString(l10n)),
              if (loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: errorMessage == null ? send : null,
                  child: Text(l10n.send),
                ),
              ErrorText(error, l10n.errorReporting),
            ],
          ),
        ),
      ),
    );
  }

  void send() async {
    var pos = get<LocationProvider>().lastLocationInfo().position;
    var mt = markerType;
    if (pos == null || images.isEmpty || mt == null || mt == MarkerType.unknown) {
      return; // this should be unreachable, since "Send" should be hidden
    }

    setState(() {
      loading = true;
      error = null;
    });

    final backend = get<Backend>();
    backend.addMarker(pos.latitude, pos.longitude, mt).then(
      (markerUpdate) {
        get<AuthUserProvider>().addPoints(markerUpdate.earnedPoints);

        // temporary map marker used only locally
        var mapMarker = MapMarker(markerUpdate.id, pos.latitude, pos.longitude, mt, DateTime.now(),
            null, -1 /* TODO we don't know our user id */, null);
        Future.wait(images.map((e) => backend.addMarkerImage(markerUpdate.id, e.first, e.second)))
            .then(
          (_) => Navigator.pop(context, ReportedResult(mapMarker, null)),
          onError: (e) => Navigator.pop(context, ReportedResult(mapMarker, e.toString())),
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
