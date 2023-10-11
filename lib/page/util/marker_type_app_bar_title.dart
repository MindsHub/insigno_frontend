import 'package:flutter/material.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';

class MarkerTypeAppBarTitle extends StatelessWidget {
  final MarkerType markerType;

  const MarkerTypeAppBarTitle(this.markerType, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(markerType.getName(context)),
          const SizedBox(width: 12),
          markerType.getThemedIcon(context)
        ],
      ),
    );
  }
}
