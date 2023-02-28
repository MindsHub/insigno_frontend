import 'package:flutter/material.dart';
import 'package:insignio_frontend/map/map_widget.dart';

class MapPersistentPage extends StatefulWidget {
  @override
  State<MapPersistentPage> createState() => _MapPersistentPageState();
}

class _MapPersistentPageState extends State<MapPersistentPage>
    with AutomaticKeepAliveClientMixin<MapPersistentPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MapWidget();
  }

  @override
  bool get wantKeepAlive => true;
}
