import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/map/map_widget.dart';
import 'package:insignio_frontend/networking/extractor.dart';

import 'location.dart';
import '../networking/data/pill.dart';
import 'location_info.dart';

class MapPage extends StatefulWidget with GetItStatefulWidgetMixin {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with GetItStateMixin<MapPage>, SingleTickerProviderStateMixin {
  Pill? pill;
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
    final position = watchStream(
            (LocationProvider location) => location.getLocationStream(), LocationInfo.initial())
        .data
        ?.position;

    return Scaffold(
      appBar: AppBar(title: const Text("Insignio")),
      body: MapWidget(),
      bottomNavigationBar: SizeTransition(
          sizeFactor: pillAnimation,
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
                      child: Text(pill?.text ?? "", textAlign: TextAlign.center))),
              IconButton(
                  onPressed: () => pillAnimationController.reverse(),
                  icon: const Icon(Icons.close))
            ],
          )),
      floatingActionButton: (position == null) ? null : FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
