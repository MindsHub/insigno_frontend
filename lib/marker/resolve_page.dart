import 'package:flutter/material.dart';

import '../networking/data/map_marker.dart';

class ResolvePage extends StatefulWidget {
  static const routeName = '/resolvePage';

  final MapMarker mapMarker;

  const ResolvePage(this.mapMarker, {Key? key}) : super(key: key);

  @override
  State<ResolvePage> createState() => _ResolvePageState();
}

class _ResolvePageState extends State<ResolvePage> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.mapMarker.id.toString());
  }
}
