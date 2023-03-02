import 'package:flutter/material.dart';

enum MarkerType {
  unknown(1, Colors.grey, Icons.help),
  plastic(2, Colors.indigo, Icons.polymer),
  paper(3, Colors.yellow, Icons.auto_stories),
  undifferentiated(4, Colors.red, Icons.broken_image),
  glass(5, Colors.green, Icons.liquor),
  compost(6, Colors.brown, Icons.compost),
  electronics(7, Colors.white, Icons.local_laundry_service);

  final int id;
  final Color color;
  final IconData icon;
  const MarkerType(this.id, this.color, this.icon);
}
