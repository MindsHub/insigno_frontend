import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/page/map/additional_points_widget.dart';
import 'package:insigno_frontend/page/map/bottom_controls_widget.dart';
import 'package:insigno_frontend/page/map/fast_markers_layer.dart';
import 'package:insigno_frontend/page/map/map_controls_widget.dart';
import 'package:insigno_frontend/page/map/pill_widget.dart';
import 'package:insigno_frontend/page/map/settings_controls_widget.dart';
import 'package:insigno_frontend/page/marker/marker_page.dart';
import 'package:insigno_frontend/page/marker/report_page.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:insigno_frontend/provider/location_provider.dart';
import 'package:insigno_frontend/provider/map_marker_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget with GetItStatefulWidgetMixin {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

const LatLng defaultInitialCoordinates = LatLng(45.75548, 11.00323);
const double defaultInitialZoom = 16.0;

class _MapPageState extends State<MapPage> with GetItStateMixin<MapPage>, WidgetsBindingObserver {
  late final SharedPreferences prefs;
  late final MapMarkerProvider mapMarkerProvider;
  final MapController mapController = MapController();

  late LatLng initialCoordinates;
  late double initialZoom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // needed to keep track of app lifecycle

    mapMarkerProvider = MapMarkerProvider(get<Backend>(), () => setState(() {}));
    mapMarkerProvider.connectToMapEventStream(mapController.mapEventStream);

    prefs = get<SharedPreferences>();
    initialCoordinates = LatLng(
      prefs.getDouble(lastMapLatitude) ?? defaultInitialCoordinates.latitude,
      prefs.getDouble(lastMapLongitude) ?? defaultInitialCoordinates.longitude,
    );
    initialZoom = prefs.getDouble(lastMapZoom) ?? defaultInitialZoom;

    mapMarkerProvider.loadMarkers(initialCoordinates);
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
      prefs.setDouble(lastMapLatitude, mapController.camera.center.latitude),
      prefs.setDouble(lastMapLongitude, mapController.camera.center.longitude),
      prefs.setDouble(lastMapZoom, mapController.camera.zoom),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;

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
            interactionOptions: const InteractionOptions(
              flags: (InteractiveFlag.all | InteractiveFlag.doubleTapDragZoom) &
                  ~InteractiveFlag.rotate,
            ),
            initialCenter: initialCoordinates,
            initialZoom: initialZoom,
            // OSM supports at most the zoom value 19
            maxZoom: 18.45,
            onTap: (tapPosition, tapLatLng) {
              final minMarker = mapMarkerProvider.getClosestMarker(tapLatLng);
              if (minMarker == null) {
                return;
              }

              final markerScale = markerScaleFromMapZoom(mapController.camera.zoom);
              final screenPoint = mapController.camera.latLngToScreenPoint(minMarker.getLatLng());
              final dx = (tapPosition.global.dx - screenPoint.x).abs();
              final dy = (tapPosition.global.dy - screenPoint.y).abs();
              if (max(dx, dy) < markerScale * 0.7) {
                openMarkerPage(minMarker);
              }
            }),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
              markers: [position?.toLatLng()]
                  .whereType<LatLng>()
                  .map((pos) => Marker(
                        rotate: true,
                        point: pos,
                        child: SvgPicture.asset("assets/icons/current_location.svg"),
                      ))
                  .toList()),
          FastMarkersLayer(mapMarkerProvider.getVisibleMarkers()),
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
            child: SettingsControlsWidget(() =>
                mapMarkerProvider.openMarkerFiltersDialog(context, mapController.camera.center)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomControlsWidget(openReportPage),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: PillWidget(),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: AdditionalPointsWidget(),
          ),
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
        setState(() => mapMarkerProvider.addOrReplace(value));
      }
    });
  }

  void openReportPage() {
    Navigator.pushNamed(context, ReportPage.routeName).then((value) {
      if (value is ReportedResult) {
        setState(() => mapMarkerProvider.addOrReplace(value.newMapMarker));
        openMarkerPage(value.newMapMarker, value.errorAddingImages);
      }
    });
  }
}
