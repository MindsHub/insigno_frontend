import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/marker/report_as_inappropriate_dialog.dart';
import 'package:insigno_frontend/marker/resolve_page.dart';
import 'package:insigno_frontend/networking/const.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker.dart';
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
  List<int>? images;
  Marker? marker;
  String? resolveError;
  bool wasResolvedNow = false;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    final backend = get<Backend>();
    backend.getImagesForMarker(widget.mapMarker.id).then((value) => setState(() => images = value));
    backend.getMarker(widget.mapMarker.id).then((value) => setState(() => marker = value));
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

    final imageProviders = images?.map((image) => Image.network(
          "$insignoServerScheme://$insignoServer/map/image/$image",
          height: 128,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ));

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(mapMarker.type.getName(context)),
          const SizedBox(width: 12),
          mapMarker.type.getThemedIcon(context)
        ]),
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
          Navigator.pop(context, wasResolvedNow);
          return false;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (images?.isNotEmpty == true)
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
                )
              else if (images == null)
                const SizedBox(
                  height: 128,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (widget.errorAddingImages != null || resolveError != null)
                const SizedBox(height: 16),
              if (widget.errorAddingImages != null)
                Text(l10n.errorUploadingReportImages(widget.errorAddingImages!)),
              if (resolveError != null) Text(l10n.errorUploadingResolveImages(resolveError!)),
              const SizedBox(height: 16),
              if (marker == null) const CircularProgressIndicator(),
              if (marker == null || marker?.resolutionDate != null)
                const SizedBox() // do not show any error if the marker is already resolved
              else if (!isLoggedIn)
                Text(l10n.loginToResolve)
              else if (!nearEnoughToResolve)
                Text(l10n.getCloserToResolve),
              if (marker != null)
                ElevatedButton(
                  onPressed: (marker?.resolutionDate == null && isLoggedIn && nearEnoughToResolve)
                      ? openResolvePage
                      : null,
                  child: Text(marker?.resolutionDate == null ? l10n.resolve : l10n.alreadyResolved),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void openResolvePage() {
    Navigator.pushNamed(context, ResolvePage.routeName, arguments: marker!).then((value) {
      if (value is ResolvedResult) {
        wasResolvedNow = true;
        setState(() => resolveError = value.errorAddingImages);
        reload();
      }
    });
  }

  void openReportAsInappropriateDialog() {
    showDialog(context: context, builder: (ctx) => const ReportAsInappropriateDialog())
        .then((value) {
      if (value is bool && value == true) {
        get<Backend>().reportAsInappropriate(marker!.id);
      }
    });
  }
}
