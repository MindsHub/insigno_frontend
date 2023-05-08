import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/marker/add_images_widget.dart';
import 'package:insigno_frontend/marker/report_as_inappropriate_dialog.dart';
import 'package:insigno_frontend/marker/resolve_page.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker.dart';
import 'package:insigno_frontend/user/user_page.dart';
import 'package:insigno_frontend/util/error_text.dart';
import 'package:insigno_frontend/util/image.dart';
import 'package:insigno_frontend/util/iterable.dart';
import 'package:insigno_frontend/util/nullable.dart';

import '../map/location_provider.dart';
import '../networking/authentication.dart';
import '../networking/backend.dart';

class MarkerPage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = '/markerPage';

  final MapMarker mapMarker;
  final String? errorAddingImages;

  MarkerPage(MarkerPageArgs args, {super.key})
      : mapMarker = args.mapMarker,
        errorAddingImages = args.errorAddingImages;

  @override
  State<MarkerPage> createState() => _MarkerPageState();
}

class MarkerPageArgs {
  final MapMarker mapMarker;
  final String? errorAddingImages;

  MarkerPageArgs(this.mapMarker, this.errorAddingImages);
}

class _MarkerPageState extends State<MarkerPage> with GetItStateMixin<MarkerPage> {
  Marker? marker;
  String? markerError;
  String? resolveError;
  String? reportAsInappropriateError;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    final backend = get<Backend>();
    backend.getMarker(widget.mapMarker.id).then((value) => setState(() => marker = value),
        onError: (e) => markerError = e.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final MapMarker mapMarker = (marker ?? widget.mapMarker);
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
            .data ??
        false;
    final bool nearEnoughToResolve =
        position?.position?.map(mapMarker.isNearEnoughToResolve) ?? false;

    final imageProviders = marker?.images
        .map((image) => imageFromNetwork(imageId: image, height: AddImagesWidget.imageHeight));

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mapMarker.type.getName(context)),
              const SizedBox(width: 12),
              mapMarker.type.getThemedIcon(context)
            ],
          ),
        ),
        actions: isLoggedIn && (marker?.canBeReported ?? false)
            ? [
                IconButton(
                  onPressed: openReportAsInappropriateDialog,
                  icon: const Icon(Icons.report),
                  tooltip: l10n.reportAsInappropriate,
                )
              ]
            : null,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, marker); // pass the up-to-date loaded marker to the parent
          return false;
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (marker?.images.isNotEmpty == true)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: imageProviders!
                          .expandIndexed(
                            (index, image) => [
                              if (index == 0) const SizedBox(width: 16),
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(16)),
                                child: GestureDetector(
                                  onTap: () {
                                    var imageProvider = MultiImageProvider(
                                      imageProviders.map((e) => e.image).toList(growable: false),
                                      initialIndex: index,
                                    );
                                    showImageViewerPager(
                                      context,
                                      imageProvider,
                                      closeButtonTooltip: l10n.close,
                                      doubleTapZoomable: true,
                                    );
                                  },
                                  child: image,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          )
                          .toList(growable: false),
                    ),
                  ),
                ErrorText(markerError, l10n.errorLoading),
                ErrorText(
                  widget.errorAddingImages,
                  l10n.errorUploadingReportImages,
                  topPadding: 16,
                ),
                ErrorText(resolveError, l10n.errorUploadingResolveImages, topPadding: 16),
                ErrorText(
                  reportAsInappropriateError,
                  l10n.errorReportingAsInappropriate,
                  topPadding: 16,
                ),
                const SizedBox(
                  height: 16,
                  width: double.infinity, // to make the column have maximum width
                ),
                if (marker == null || marker?.resolutionDate != null)
                  const SizedBox() // do not show any error if the marker is already resolved
                else if (!isLoggedIn)
                  Text(l10n.loginToResolve, textAlign: TextAlign.center)
                else if (!nearEnoughToResolve)
                  Text(l10n.getCloserToResolve, textAlign: TextAlign.center),
                if (marker == null)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: (marker?.resolutionDate == null && isLoggedIn && nearEnoughToResolve)
                        ? openResolvePage
                        : null,
                    child:
                        Text(marker?.resolutionDate == null ? l10n.resolve : l10n.alreadyResolved),
                  ),
                if (marker != null) const SizedBox(height: 8),
                if (marker != null)
                  OverflowBar(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, UserPage.routeName,
                            arguments: mapMarker.reportedBy),
                        child: Text(l10n.reportedBy(marker!.reportedByUser.name)),
                      ),
                      if (marker!.resolvedByUser != null)
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, UserPage.routeName,
                              arguments: mapMarker.resolvedBy),
                          child: Text(l10n.resolvedBy(marker!.resolvedByUser!.name)),
                        ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openResolvePage() {
    Navigator.pushNamed(context, ResolvePage.routeName, arguments: marker!).then((value) {
      if (value is ResolvedResult) {
        setState(() {
          resolveError = value.errorAddingImages;

          final m = marker;
          if (m != null) {
            // temporarily update value while everything is being reloaded
            marker = Marker(
              m.id,
              m.latitude,
              m.longitude,
              m.type,
              m.creationDate,
              DateTime.now(),
              m.reportedByUser,
              null /* will be updated after reloading */,
              m.images,
              m.canBeReported,
            );
          }
        });
        reload();
      }
    });
  }

  void openReportAsInappropriateDialog() {
    showDialog(context: context, builder: (ctx) => const ReportAsInappropriateDialog())
        .then((value) {
      if (value is bool && value == true) {
        setState(() {
          final m = marker;
          if (m != null) {
            // make sure the user won't be able to report again
            marker = Marker(m.id, m.latitude, m.longitude, m.type, m.creationDate, m.resolutionDate,
                m.reportedByUser, m.resolvedByUser, m.images, false);
          }
        });

        get<Backend>().reportAsInappropriate(marker!.id).then((value) {
          /* reported successfully */
        }, onError: (e) {
          setState(() {
            reportAsInappropriateError = e.toString();

            final m = marker;
            if (m != null) {
              // allow reporting again
              marker = Marker(
                m.id,
                m.latitude,
                m.longitude,
                m.type,
                m.creationDate,
                m.resolutionDate,
                m.reportedByUser,
                m.resolvedByUser,
                m.images,
                true,
              );
            }
          });
        });
      }
    });
  }
}
