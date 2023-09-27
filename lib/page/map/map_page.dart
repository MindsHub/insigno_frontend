import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:insigno_frontend/page/map/fast_markers_layer.dart';
import 'package:insigno_frontend/page/map/location_provider.dart';
import 'package:insigno_frontend/page/map/map_controls_widget.dart';
import 'package:insigno_frontend/page/map/marker_filters_dialog.dart';
import 'package:insigno_frontend/page/map/pill_widget.dart';
import 'package:insigno_frontend/page/map/settings_controls_widget.dart';
import 'package:insigno_frontend/page/marker/marker_page.dart';
import 'package:insigno_frontend/page/marker/report_page.dart';
import 'package:insigno_frontend/page/user/login_flow_page.dart';
import 'package:insigno_frontend/page/user/profile_page.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:insigno_frontend/util/error_messages.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget with GetItStatefulWidgetMixin {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

const LatLng defaultInitialCoordinates = LatLng(45.75548, 11.00323);
const double defaultInitialZoom = 16.0;
const double markersZoomThreshold = 14.0;
const Duration fabAnimDuration = Duration(milliseconds: 200);

class _MapPageState extends State<MapPage>
    with GetItStateMixin<MapPage>, WidgetsBindingObserver, TickerProviderStateMixin {
  late final SharedPreferences prefs;
  final Distance distance = const Distance();
  final MapController mapController = MapController();

  late LatLng initialCoordinates;
  late double initialZoom;
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

    if (initialZoom >= markersZoomThreshold) {
      loadMarkers(initialCoordinates);
    }

    // check whether this version of insigno is compatible with the backend, ignoring any errors
    get<Backend>().isCompatible().then((value) => setState(() => isVersionCompatible = value),
        onError: (e) => debugPrint("Could not check whether this version is compatible: $e"));
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

    // Uncomment to test the rendering performance with lots of markers
    /*markers = <MapMarker>[];
    for (int i = 0; i < 100; ++i) {
      for (int j = 0; j < 100; ++j) {
        markers.add(MapMarker(
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
    }*/

    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            center: initialCoordinates,
            zoom: initialZoom,
            // OSM supports at most the zoom value 19
            maxZoom: 18.45,
            onTap: (tapPosition, tapLatLng) {
              const distance = Distance();
              final minMarker =
                  minBy(markers, (MapMarker marker) => distance(tapLatLng, marker.getLatLng()));
              if (minMarker == null) {
                return;
              }

              final markerScale = markerScaleFromMapZoom(mapController.zoom);
              final screenPoint = mapController.latLngToScreenPoint(minMarker.getLatLng());
              final dx = (tapPosition.global.dx - screenPoint.x).abs();
              final dy = (tapPosition.global.dy - screenPoint.y).abs();
              if (max(dx, dy) < markerScale * 0.7) {
                openMarkerPage(minMarker);
              }
            }),
        nonRotatedChildren: [
          const Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              " © OpenStreetMap contributors",
              style: TextStyle(color: Color.fromARGB(255, 127, 127, 127)), // theme-independent grey
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: MapControlsWidget(mapController),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SettingsControlsWidget(openMarkerFiltersDialog),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: FloatingActionButton(
                heroTag: "addMarker",
                onPressed: errorMessage == null ? openReportPage : null,
                tooltip: l10n.report,
                backgroundColor: errorMessage == null
                    ? null
                    : theme.colorScheme.primaryContainer.withOpacity(0.38),
                foregroundColor: errorMessage == null
                    ? null
                    : theme.colorScheme.onPrimaryContainer.withOpacity(0.38),
                disabledElevation: 0,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: FloatingActionButton(
                heroTag: "user",
                onPressed: isLoggedIn == null
                    ? null
                    : () => Navigator.pushNamed(context,
                        isLoggedIn == true ? ProfilePage.routeName : LoginFlowPage.routeName),
                tooltip: isLoggedIn == true ? l10n.user : l10n.login,
                child: isLoggedIn == true ? const Icon(Icons.person) : const Icon(Icons.login),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: PillWidget(),
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
              markers: [position?.toLatLng()]
                  .whereType<LatLng>()
                  .map((pos) => Marker(
                        rotate: true,
                        point: pos,
                        builder: (ctx) => SvgPicture.asset("assets/icons/current_location.svg"),
                      ))
                  .toList()),
          FastMarkersLayer(markers.where((e) =>
              (markerFilters.includeResolved || !e.isResolved()) &&
              markerFilters.shownMarkers.contains(e.type))),
        ],
      ),
    );
  }

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
