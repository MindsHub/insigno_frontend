import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/user_persistent_page.dart';
import 'package:insignio_frontend/map/map_persistent_page.dart';
import 'package:insignio_frontend/networking/extractor.dart';

import 'networking/data/pill.dart';

class HomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with GetItStateMixin<HomePage>, TickerProviderStateMixin {
  Pill? pill;
  late AnimationController pillAnimationController;
  late Animation<double> pillAnimation;

  late final List<Widget> _tabs;
  late final TabController _tabController;

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

    _tabs = <Widget>[MapPersistentPage(), UserPersistentPage()];
    _tabController = TabController(initialIndex: 0, length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {})); // <- notify when
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: _tabs,
      ),
      bottomNavigationBar: Material(
        elevation: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizeTransition(
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
              ),
            ),
            BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "User")
              ],
              currentIndex: _tabController.index,
              onTap: (i) => _tabController.animateTo(i),
              elevation: 0,
            )
          ],
        ),
      ),
    );
  }
}
