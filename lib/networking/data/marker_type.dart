import 'package:flutter/material.dart';

enum MarkerType {
  unknown(-1, Colors.grey, Icons.help),
  plastic(0, Colors.indigo, Icons.polymer),
  paper(0, Colors.yellow, Icons.auto_stories),
  undifferentiated(0, Colors.red, Icons.broken_image),
  glass(0, Colors.green, Icons.liquor),
  compost(0, Colors.brown, Icons.compost),
  electronics(0, Colors.white, Icons.local_laundry_service);

  final int id;
  final Color color;
  final IconData icon;
  const MarkerType(this.id, this.color, this.icon);
}
