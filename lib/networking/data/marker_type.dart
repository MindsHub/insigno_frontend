import 'package:flutter/material.dart';

enum MarkerType {
  unknown(1, Colors.grey, Icons.help, "Unknown type"),
  plastic(2, Colors.indigo, Icons.polymer, "Plastic"),
  paper(3, Colors.yellow, Icons.auto_stories, "Paper"),
  undifferentiated(4, Colors.red, Icons.broken_image, "Undifferentiated"),
  glass(5, Colors.green, Icons.liquor, "Glass"),
  compost(6, Colors.brown, Icons.compost, "Compost"),
  electronics(7, Colors.white, Icons.local_laundry_service, "Electronics");

  final int id;
  final Color color;
  final IconData icon;
  final String name;

  const MarkerType(this.id, this.color, this.icon, this.name);

  Icon getThemedIcon(final BuildContext context) {
    return Icon(icon,
        color: HSLColor.fromColor(color)
            .withLightness(
            Theme
                .of(context)
                .brightness == Brightness.dark ? 0.7 : 0.3)
            .toColor());
  }
}
