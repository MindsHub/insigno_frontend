import 'package:flutter/material.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';

class MarkerWidget extends StatelessWidget {
  final MapMarker marker;
  final double size;
  final void Function(MapMarker) onPressed;

  const MarkerWidget(this.marker, this.size, this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        marker.type.icon,
        color: marker.type.color,
        size: size,
        shadows: [Shadow(color: Colors.black45, blurRadius: size * 0.12)],
      ),
      onPressed: () => onPressed(marker),
    );
  }
}
