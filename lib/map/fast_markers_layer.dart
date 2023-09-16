import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:latlong2/latlong.dart';

import '../networking/data/map_marker.dart';

class FastMarkersLayer extends StatelessWidget {
  static const double markersZoomThreshold = 14.0;

  final List<MapMarker> markers;

  const FastMarkersLayer(this.markers, {super.key});

  @override
  Widget build(BuildContext context) {
    final mapState = FlutterMapState.of(context);
    final markerSizeMultiplier = 10 + 17.0 * (
        mapState.zoom < 16.0
        ? pow(2.0, mapState.zoom - 16.0)
        : pow(mapState.zoom - 15.0, 0.7)
    );

    return Stack(
      children: markers.map((marker) {
        final pxPoint = mapState.project(LatLng(marker.latitude, marker.longitude));
        final pos = pxPoint - mapState.pixelOrigin;

        return Positioned(
          left: pos.x,
          top: pos.y,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _FastMarkerPainter(marker.type, markerSizeMultiplier),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FastMarkerPainter extends CustomPainter {
  final MarkerType markerType;
  final double fontSize;

  const _FastMarkerPainter(this.markerType, this.fontSize);

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(markerType.icon.codePoint),
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: markerType.icon.fontFamily,
        color: markerType.color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0, 0));
  }

  @override
  bool shouldRepaint(_FastMarkerPainter oldDelegate) => oldDelegate.fontSize != fontSize;
}
