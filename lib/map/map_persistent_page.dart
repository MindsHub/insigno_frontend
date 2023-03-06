import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/map/location_provider.dart';
import 'package:insignio_frontend/marker/report_page.dart';
import 'package:insignio_frontend/pref/preferences_keys.dart';
import 'package:latlong2/latlong.dart';
import 'package:insignio_frontend/marker/marker_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/authentication.dart';
import '../di/setup.dart';
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
        WidgetsBindingObserver {
  static final LatLng defaultInitialCoordinates = LatLng(45.75548, 11.00323);
  static const double defaultInitialZoom = 15.0;

  late final SharedPreferences prefs;
  final Distance distance = const Distance();
  final MapController mapController = MapController();

  late LatLng initialCoordinates;
  late double initialZoom;
  LatLng? lastLoadMarkersPos;
  List<MapMarker> markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    mapController.mapEventStream
        .where((event) =>
            event.zoom >= 15.0 &&
            (lastLoadMarkersPos == null ||
                distance.distance(lastLoadMarkersPos!, event.center) > 5000))
        .forEach((event) {
      lastLoadMarkersPos = event.center;
      loadMarkers(event.center);
    });

    mapController.mapEventStream.where((event) => event.zoom < 15.0).forEach((element) {
      lastLoadMarkersPos = null;
      setState(() {
        markers = [];
      });
    });

    prefs = getIt<SharedPreferences>();
    initialCoordinates = LatLng(
      prefs.getDouble(lastMapLatitude) ?? defaultInitialCoordinates.latitude,
      prefs.getDouble(lastMapLongitude) ?? defaultInitialCoordinates.longitude,
    );
    initialZoom = prefs.getDouble(lastMapZoom) ?? defaultInitialZoom;

    if (initialZoom >= 15.0) {
      loadMarkers(initialCoordinates);
    }
  }

  void loadMarkers(final LatLng latLng) async {
    loadMapMarkers(latLng.latitude, latLng.longitude)
        .then((value) => setState(() => markers = value));
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
            getIt<LocationProvider>().lastLocationInfo())
        .data;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                getIt<Authentication>().isLoggedIn())
            .data ??
        false;

    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: initialCoordinates,
          zoom: initialZoom,
          maxZoom: 18.45, // OSM supports at most the zoom value 19
        ),
        nonRotatedChildren: [
          AttributionWidget(attributionBuilder: (_) {
            return const Text(
              "© OpenStreetMap contributors",
              style: TextStyle(color: Color.fromARGB(255, 127, 127, 127)), // theme-independent grey
            );
          })
        ],
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
              markers: [position?.position]
                  .whereType<Position>()
                  .map((pos) => Marker(
                        rotate: true,
                        point: LatLng(pos.latitude, pos.longitude),
                        builder: (ctx) => SvgPicture.asset("assets/icons/current_location.svg"),
                      ))
                  .followedBy(markers.map((e) => Marker(
                        width: 44,
                        height: 44,
                        rotate: true,
                        point: LatLng(e.latitude, e.longitude),
                        builder: (ctx) => IconButton(
                          icon: Icon(e.type.icon, color: e.type.color, size: 28),
                          onPressed: () => {
                            Navigator.pushNamed(context, MarkerPage.routeName,
                                arguments: MarkerPageArgs(e))
                          },
                        ),
                      )))
                  .toList(growable: false)),
        ],
      ),
      floatingActionButton: (position?.position == null || !isLoggedIn)
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, ReportPage.routeName),
              child: const Icon(Icons.add),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
