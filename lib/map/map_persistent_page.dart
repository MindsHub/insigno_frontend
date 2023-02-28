import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/map/location.dart';
import 'package:insignio_frontend/map/map_widget.dart';

import '../di/setup.dart';

class MapPersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  MapPersistentPage({super.key});

  @override
  State<MapPersistentPage> createState() => _MapPersistentPageState();
}

class _MapPersistentPageState extends State<MapPersistentPage>
    with AutomaticKeepAliveClientMixin<MapPersistentPage>, GetItStateMixin<MapPersistentPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final position = watchStream((LocationProvider location) => location.getLocationStream(),
        getIt<LocationProvider>().lastLocationInfo())
        .data;
    print((position?.position.toString() ?? "null") +
        " " +
        (position?.servicesEnabled.toString() ?? "boh") +
        " " +
        (position?.permissionGranted.toString() ?? "boh"));

    return Scaffold(
      body: MapWidget(),
      floatingActionButton: position?.position == null
          ? null
          : FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      // TODO share floatingActionButtonAnimator across pages
    );
  }

  @override
  bool get wantKeepAlive => true;
}
