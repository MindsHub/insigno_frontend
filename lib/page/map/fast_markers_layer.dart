import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:latlong2/latlong.dart';

const int atlasImageSize = 512;
const double atlasImageSizeDouble = 512.0;

double markerScaleFromMapZoom(double mapZoom) {
  return 10 + 17.0 * (mapZoom < 16.0 ? pow(2.0, mapZoom - 16.0) : pow(mapZoom - 15.0, 0.7));
}

class FastMarkersLayer extends StatefulWidget {
  final Iterable<MapMarker> markers;

  const FastMarkersLayer(this.markers, {super.key});

  @override
  State<FastMarkersLayer> createState() => _FastMarkersLayerState();
}

class _FastMarkersLayerState extends State<FastMarkersLayer> {
  ui.Image? atlasImage;

  @override
  void initState() {
    super.initState();
    prepareAtlasImage();
  }

  void prepareAtlasImage() async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);

    for (int i = 0; i < MarkerType.values.length; ++i) {
      final markerType = MarkerType.values[i];
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(markerType.icon.codePoint),
        style: TextStyle(
          fontSize: atlasImageSizeDouble * 0.8,
          fontFamily: markerType.icon.fontFamily,
          color: markerType.color,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(atlasImageSizeDouble * (0.1 + i), atlasImageSizeDouble * 0.1),
      );
    }

    var picture = pictureRecorder.endRecording();
    final imageWithoutShadow =
        await picture.toImage(atlasImageSize * MarkerType.values.length, atlasImageSize);

    pictureRecorder = ui.PictureRecorder();
    canvas = Canvas(pictureRecorder);

    canvas.drawImage(
      imageWithoutShadow,
      Offset.zero,
      Paint()
        ..colorFilter = const ColorFilter.mode(Colors.grey, BlendMode.srcIn)
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
    );
    canvas.drawImage(
      imageWithoutShadow,
      Offset.zero,
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
    );

    picture = pictureRecorder.endRecording();
    final imageWithShadow =
        await picture.toImage(atlasImageSize * MarkerType.values.length, atlasImageSize);

    setState(() {
      atlasImage = imageWithShadow;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (atlasImage == null) {
      return const SizedBox.shrink();
    }

    final mapState = MapCamera.of(context);
    final markerScale = markerScaleFromMapZoom(mapState.zoom);

    return RepaintBoundary(
      child: CustomPaint(
        painter: _FastMarkerPainter(atlasImage!, mapState, widget.markers, markerScale),
      ),
    );
  }
}

class _FastMarkerPainter extends CustomPainter {
  final ui.Image atlasImage;
  final MapCamera mapState;
  final Iterable<MapMarker> markers;
  final double scale;

  const _FastMarkerPainter(this.atlasImage, this.mapState, this.markers, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawAtlas(
      atlasImage,
      markers.map((marker) {
        final pos = mapState.project(LatLng(marker.latitude, marker.longitude)) -
            mapState.pixelOrigin.toDoublePoint();
        return RSTransform.fromComponents(
          rotation: 0.0,
          scale: scale / atlasImageSizeDouble / 0.8,
          anchorX: atlasImageSizeDouble / 2,
          anchorY: atlasImageSizeDouble / 2,
          translateX: pos.x,
          translateY: pos.y,
        );
      }).toList(),
      markers.map((marker) {
        return Rect.fromLTWH(
          atlasImageSizeDouble * marker.type.index,
          0,
          atlasImageSizeDouble,
          atlasImageSizeDouble,
        );
      }).toList(),
      null,
      null,
      null,
      Paint()..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_FastMarkerPainter oldDelegate) => true;
}
