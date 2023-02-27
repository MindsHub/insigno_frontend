import 'package:flutter/material.dart';
import '../../networking/data/map_marker.dart';

class MarkerWidget extends StatefulWidget {
  const MarkerWidget({Key? key}) : super(key: key);

  static const routeName = '/markerWidget';

  @override
  State<MarkerWidget> createState() => MarkerWidgetState();
}

class MarkerWidgetArgs {
  final MapMarker mapMarker;

  MarkerWidgetArgs(this.mapMarker);
}

class MarkerWidgetState extends State<MarkerWidget> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as MarkerWidgetArgs;
    
    return Scaffold(
        body: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(args.mapMarker.type.name),
            )
        )
    );
  }
}