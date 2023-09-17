import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/map/fast_markers_layer.dart';
import 'package:insigno_frontend/map/location_provider.dart';
import 'package:insigno_frontend/map/marker_filters_dialog.dart';
import 'package:insigno_frontend/map/marker_widget.dart';
import 'package:insigno_frontend/marker/marker_page.dart';
import 'package:insigno_frontend/marker/report_page.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:insigno_frontend/util/error_messages.dart';
import 'package:insigno_frontend/util/stream.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../networking/authentication.dart';
import '../networking/backend.dart';
import '../networking/data/map_marker.dart';

class MapPersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  MapPersistentPage({super.key});

  @override
  State<MapPersistentPage> createState() => _MapPersistentPageState();
}

class _MapPersistentPageState extends State<MapPersistentPage>
    with
        AutomaticKeepAliveClientMixin<MapPersistentPage>,
        GetItStateMixin<MapPersistentPage>,
        WidgetsBindingObserver,
        TickerProviderStateMixin {
  static const LatLng defaultInitialCoordinates = LatLng(45.75548, 11.00323);
  static const double defaultInitialZoom = 16.0;
  static const double markersZoomThreshold = 14.0;
  static const Duration fabAnimDuration = Duration(milliseconds: 200);

  late final SharedPreferences prefs;
  final Distance distance = const Distance();
  final MapController mapController = MapController();
  late final AnimationController repositionAnim;
  late final AnimationController addMarkerAnim;

  late LatLng initialCoordinates;
  late double initialZoom;
  late Stream<double> zoomStream;
  LatLng? lastLoadMarkersPos;
  bool lastLoadMarkersIncludeResolved = false;
  MarkerFilters markerFilters = MarkerFilters(Set.unmodifiable(MarkerType.values), false);
  List<MapMarker> markers = [];
  PictureInfo? pictureInfo;

  String lastErrorMessage = "";
  late final AnimationController errorMessageAnim;
  bool isVersionCompatible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // needed to keep track of app lifecycle

    repositionAnim = AnimationController(vsync: this, duration: fabAnimDuration);
    addMarkerAnim = AnimationController(vsync: this, duration: fabAnimDuration);
    errorMessageAnim = AnimationController(vsync: this, duration: fabAnimDuration);

    mapController.mapEventStream
        .where((event) =>
            event.zoom >= markersZoomThreshold &&
            (lastLoadMarkersPos == null ||
                distance.distance(lastLoadMarkersPos!, event.center) > 5000))
        .forEach((event) => loadMarkers(event.center));

    prefs = get<SharedPreferences>();
    initialCoordinates = LatLng(
      prefs.getDouble(lastMapLatitude) ?? defaultInitialCoordinates.latitude,
      prefs.getDouble(lastMapLongitude) ?? defaultInitialCoordinates.longitude,
    );
    initialZoom = prefs.getDouble(lastMapZoom) ?? defaultInitialZoom;
    zoomStream = Stream.value(initialZoom)
        // use mapController.zoom instead of event.zoom since event.zoom is sometimes outdated
        // (e.g. after repositioning)
        .concatWith([mapController.mapEventStream.map((event) => mapController.zoom)]);

    if (initialZoom >= markersZoomThreshold) {
      loadMarkers(initialCoordinates);
    }

    // check whether this version of insigno is compatible with the backend, ignoring any errors
    get<Backend>().isCompatible().then((value) => setState(() => isVersionCompatible = value),
        onError: (e) => debugPrint("Could not check whether this version is compatible: $e"));

    loadPictureInfo();
  }

  void loadPictureInfo() async {
    var thePictureInfo =
        await vg.loadPicture(SvgAssetLoader("assets/icons/current_location.svg"), null);
    setState(() {
      pictureInfo = thePictureInfo;
    });
  }

  void loadMarkers(final LatLng latLng) async {
    lastLoadMarkersPos = latLng;
    lastLoadMarkersIncludeResolved = markerFilters.includeResolved;
    get<Backend>()
        .loadMapMarkers(latLng.latitude, latLng.longitude, lastLoadMarkersIncludeResolved)
        .then((value) {
      if (latLng == lastLoadMarkersPos) {
        debugPrint("Loaded markers at $latLng");
        setState(() => markers = value);
      } else {
        debugPrint("Ignoring outdated loaded markers at $latLng");
      }
    });
    // ignore errors when loading map markers (TODO maybe show a button to view errors somewhere?)
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      await saveMapPositionToPreferences();
    }
  }

  @override
  Future<bool> didPopRoute() async {
    await saveMapPositionToPreferences();
    return super.didPopRoute();
  }

  Future<void> saveMapPositionToPreferences() async {
    await Future.wait([
      prefs.setDouble(lastMapLatitude, mapController.center.latitude),
      prefs.setDouble(lastMapLongitude, mapController.center.longitude),
      prefs.setDouble(lastMapZoom, mapController.zoom),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;
    final isLoggedIn = watchStream(
            (Authentication authentication) => authentication.getIsLoggedInStream(),
            get<Authentication>().isLoggedIn())
        .data;

    final String? errorMessage =
        isVersionCompatible ? getErrorMessage(l10n, isLoggedIn, position) : l10n.oldVersion;
    if (errorMessage == null) {
      errorMessageAnim.reverse();
    } else {
      lastErrorMessage = errorMessage;
      errorMessageAnim.forward();
    }

    if (position?.position == null) {
      repositionAnim.reverse();
    } else {
      repositionAnim.forward();
    }

    if (errorMessage == null) {
      addMarkerAnim.forward();
    } else {
      addMarkerAnim.reverse();
    }

    var markers2 = <MapMarker>[];
    for (int i = 0; i < 100; ++i) {
      for (int j = 0; j < 100; ++j) {
        markers2.add(MapMarker(
          0,
          45.7555 + .0009 * i,
          11.0033 + .0009 * j,
          MarkerType.values[(i+j) % MarkerType.values.length],
          DateTime(2023),
          DateTime(2023),
          0,
          0,
        ));
      }
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        center: initialCoordinates,
        zoom: initialZoom,
        maxZoom: 18.45, // OSM supports at most the zoom value 19
      ),
      nonRotatedChildren: [
        const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            " © OpenStreetMap contributors",
            style: TextStyle(color: Color.fromARGB(255, 127, 127, 127)), // theme-independent grey
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // see https://stackoverflow.com/q/56315392 for why we can't use SizeTransition
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16, right: 16),
                child: FloatingActionButton(
                  heroTag: "filter",
                  onPressed: openMarkerFiltersDialog,
                  tooltip: l10n.filterMarkers,
                  child: const Icon(Icons.filter_alt),
                ),
              ),
              AnimatedBuilder(
                animation: repositionAnim,
                builder: (_, child) => ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: repositionAnim.value,
                    widthFactor: repositionAnim.value,
                    child: child,
                  ),
                ),
                child: ScaleTransition(
                  scale: repositionAnim,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16, right: 16),
                    child: FloatingActionButton(
                      heroTag: "reposition",
                      onPressed: () =>
                          mapController.move(position!.toLatLng()!, defaultInitialZoom),
                      tooltip: l10n.goToPosition,
                      child: const Icon(Icons.filter_tilt_shift),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: addMarkerAnim,
                builder: (_, child) => ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: addMarkerAnim.value,
                    widthFactor: repositionAnim.value,
                    child: child,
                  ),
                ),
                child: ScaleTransition(
                  scale: addMarkerAnim,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16, right: 16),
                    child: FloatingActionButton(
                      heroTag: "addMarker",
                      onPressed: openReportPage,
                      tooltip: l10n.report,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: errorMessageAnim,
          child: Wrap(
            children: [
              Align(
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      padding: EdgeInsets.only(
                        left: 12,
                        top: 8 + MediaQuery.of(context).padding.top,
                        right: 12,
                        bottom: 12,
                      ),
                      child: Text(
                        lastErrorMessage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        FastMarkersLayer(markers2),
        StreamBuilder<double>(
          stream: zoomStream,
          builder: (context, snapshot) {
            final zoom = snapshot.data ?? markersZoomThreshold;
            final showMarkers = zoom > markersZoomThreshold;
            final double markerSizeMultiplier =
            showMarkers ? pow(zoom - markersZoomThreshold, 0.7) * 0.5 : 0;

            return MarkerLayer(
              markers: [position?.toLatLng()]
                  .whereType<Null>()
                  .whereType<LatLng>()
                  .map((pos) => Marker(
                rotate: true,
                point: pos,
                builder: (ctx) => SvgPicture.asset("assets/icons/current_location.svg"),
              ))
                  .followedBy((showMarkers ? markers : <MapMarker>[])
                  .where((e) =>
              (markerFilters.includeResolved || !e.isResolved()) &&
                  markerFilters.shownMarkers.contains(e.type))
                  .map((e) => Marker(
                width: 36 * markerSizeMultiplier,
                height: 36 * markerSizeMultiplier,
                rotate: true,
                point: LatLng(e.latitude, e.longitude),
                builder: (ctx) => MarkerWidget(
                  e,
                  36 * markerSizeMultiplier,
                  openMarkerPage,
                ),
              )))
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  void openMarkerPage(MapMarker m, [String? errorAddingImages]) {
    Navigator.pushNamed(
      context,
      MarkerPage.routeName,
      arguments: MarkerPageArgs(m, errorAddingImages),
    ).then((value) {
      if (value is MapMarker) {
        // the marker may have been resolved, or its data might have changed, so update it
        setState(() {
          markers.removeWhere((element) => element.id == m.id);
          markers.add(value);
        });
      }
    });
  }

  void openReportPage() {
    Navigator.pushNamed(context, ReportPage.routeName).then((value) {
      if (value is ReportedResult) {
        setState(() => markers.add(value.newMapMarker));
        openMarkerPage(value.newMapMarker, value.errorAddingImages);
      }
    });
  }

  void openMarkerFiltersDialog() {
    showDialog(
      context: context,
      builder: (ctx) => MarkerFiltersDialog(markerFilters),
    ).then((newFilters) {
      if (newFilters is MarkerFilters) {
        final needToReload = newFilters.includeResolved && !lastLoadMarkersIncludeResolved;
        setState(() => markerFilters = newFilters);
        if (needToReload) {
          loadMarkers(mapController.center);
        }
      }
    });
  }
}
