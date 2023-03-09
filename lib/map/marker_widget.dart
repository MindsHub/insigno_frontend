import 'package:flutter/material.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';

import '../marker/marker_page.dart';

class MarkerWidget extends StatelessWidget {
  final MapMarker marker;
  final double size;

  const MarkerWidget(this.marker, this.size, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(marker.type.icon, color: marker.type.color, size: size),
      onPressed: () =>
          Navigator.pushNamed(context, MarkerPage.routeName, arguments: MarkerPageArgs(marker)),
    );
  }
}
