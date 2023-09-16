import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';
import 'package:latlong2/latlong.dart';

import '../networking/data/map_marker.dart';

const int atlasImageSize = 512;
const double atlasImageSizeDouble = 512.0;

class FastMarkersLayer extends StatefulWidget {
  final List<MapMarker> markers;

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
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      children: MarkerType.values
          .map((markerType) => TextSpan(
                text: String.fromCharCode(markerType.icon.codePoint),
                style: TextStyle(
                  fontSize: atlasImageSizeDouble,
                  fontFamily: markerType.icon.fontFamily,
                  color: markerType.color,
                ),
              ))
          .toList(),
    );
    textPainter.layout();

    print("prepareAtlasImage done, size: ${textPainter.width}x${textPainter.height}");

    textPainter.paint(canvas, Offset.zero);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(atlasImageSize * MarkerType.values.length, atlasImageSize);
    setState(() {
      atlasImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (atlasImage == null) {
      return const SizedBox.shrink();
    }

    final mapState = FlutterMapState.of(context);
    final fontSize = 10 +
        17.0 *
            (mapState.zoom < 16.0
                ? pow(2.0, mapState.zoom - 16.0)
                : pow(mapState.zoom - 15.0, 0.7));

    return RepaintBoundary(
      child: CustomPaint(
        painter: _FastMarkerPainter(atlasImage!, mapState, widget.markers, fontSize),
      ),
    );
  }
}

class _FastMarkerPainter extends CustomPainter {
  final ui.Image atlasImage;
  final FlutterMapState mapState;
  final List<MapMarker> markers;
  final double scale;

  const _FastMarkerPainter(this.atlasImage, this.mapState, this.markers, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawAtlas(
      atlasImage,
      markers.map((marker) {
        final pos = mapState.project(LatLng(marker.latitude, marker.longitude))
            - mapState.pixelOrigin;
        return RSTransform.fromComponents(
          rotation: 0.0,
          scale: scale / atlasImageSizeDouble,
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
