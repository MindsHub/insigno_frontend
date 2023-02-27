import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/map/map_widget.dart';
import 'package:insignio_frontend/networking/extractor.dart';

class MapPage extends StatefulWidget with GetItStatefulWidgetMixin {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with GetItStateMixin<MapPage>, SingleTickerProviderStateMixin {
  String? pill;
  late AnimationController pillAnimationController;
  late Animation<double> pillAnimation;

  @override
  void initState() {
    super.initState();
    pillAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    pillAnimation = CurvedAnimation(
      parent: pillAnimationController,
      curve: Curves.linear,
    );
    loadRandomPill().then((value) => setState(() {
      pill = value;
      pillAnimationController.forward();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Insignio")),
      body: Column(
        children: [
          Expanded(child: MapWidget()),
          SizeTransition(
              sizeFactor: pillAnimation,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
                          child: Text(pill ?? "", textAlign: TextAlign.center))),
                  IconButton(
                      onPressed: () => pillAnimationController.reverse(), icon: const Icon(Icons.close))
                ],
              ))
        ],
      ),
    );
  }
}
