import 'package:flutter/material.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';

class MarkerWidget extends StatelessWidget {
  final MapMarker marker;
  final double size;
  final void Function(MapMarker) onPressed;

  const MarkerWidget(this.marker, this.size, this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actualSize = size * (marker.isResolved() ? 0.7 : 1.0);

    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        marker.type.icon,
        color: marker.type.color,
        size: actualSize,
        shadows: [Shadow(color: Colors.black45, blurRadius: actualSize * 0.12)],
      ),
      onPressed: () => onPressed(marker),
    );
  }
}
