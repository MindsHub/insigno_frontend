import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/map/location_provider.dart';
import 'package:insigno_frontend/map/marker_widget.dart';
import 'package:insigno_frontend/marker/report_page.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/authentication.dart';
import '../networking/data/map_marker.dart';
import '../networking/extractor.dart';

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
  static final LatLng defaultInitialCoordinates = LatLng(45.75548, 11.00323);
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
  LatLng? lastLoadMarkersPos;
  List<MapMarker> markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // needed to keep track of app lifecycle

    repositionAnim = AnimationController(vsync: this, duration: fabAnimDuration);
    addMarkerAnim = AnimationController(vsync: this, duration: fabAnimDuration);

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
  }

  void loadMarkers(final LatLng latLng) async {
    lastLoadMarkersPos = latLng;
    loadMapMarkers(latLng.latitude, latLng.longitude).then((value) {
      if (latLng == lastLoadMarkersPos) {
        debugPrint("Loaded markers at $latLng");
        setState(() => markers = value);
      } else {
        debugPrint("Ignoring outdated loaded markers at $latLng");
      }
    });
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

    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data
        ?.position;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
            .data ??
        false;

    if (position == null) {
      repositionAnim.reverse();
    } else {
      repositionAnim.forward();
    }

    if (position == null || !isLoggedIn) {
      addMarkerAnim.reverse();
    } else {
      addMarkerAnim.forward();
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
        AttributionWidget(
          alignment: Alignment.bottomLeft,
          attributionBuilder: (_) {
            return const Text(
              " © OpenStreetMap contributors",
              style: TextStyle(color: Color.fromARGB(255, 127, 127, 127)), // theme-independent grey
            );
          },
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // see https://stackoverflow.com/q/56315392 for why we can't use SizeTransition
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
                      onPressed: () => mapController.move(
                          LatLng(position!.latitude, position.longitude), defaultInitialZoom),
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
                      child: const Icon(Icons.add),
                    ),
                  ),
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
        StreamBuilder<double>(
          stream: mapController.mapEventStream.map((event) => event.zoom),
          builder: (context, snapshot) {
            final zoom = snapshot.data ?? markersZoomThreshold;
            final showMarkers = zoom > markersZoomThreshold;
            final double markerSizeMultiplier =
                showMarkers ? pow(zoom - markersZoomThreshold, 0.7) * 0.5 : 0;

            return MarkerLayer(
              markers: [position]
                  .whereType<Position>()
                  .map((pos) => Marker(
                        rotate: true,
                        point: LatLng(pos.latitude, pos.longitude),
                        builder: (ctx) => SvgPicture.asset("assets/icons/current_location.svg"),
                      ))
                  .followedBy((showMarkers ? markers : []).map((e) => Marker(
                        width: 36 * markerSizeMultiplier,
                        height: 36 * markerSizeMultiplier,
                        rotate: true,
                        point: LatLng(e.latitude, e.longitude),
                        builder: (ctx) => MarkerWidget(e, 36 * markerSizeMultiplier),
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

  void openReportPage() {
    Navigator.pushNamed(context, ReportPage.routeName).then((value) {
      if (value is MapMarker) {
        setState(() => markers.add(value));
      }
    });
  }
}
