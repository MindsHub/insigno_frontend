import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/login_widget.dart';
import 'package:insignio_frontend/map/map_persistent_page.dart';
import 'package:insignio_frontend/networking/extractor.dart';

import 'di/setup.dart';
import 'map/location.dart';
import 'networking/data/pill.dart';

class HomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with GetItStateMixin<HomePage>, SingleTickerProviderStateMixin {
  Pill? pill;
  late AnimationController pillAnimationController;
  late Animation<double> pillAnimation;

  int _pageIndex = 0;
  late final List<Widget> _pages;
  late final PageController _pageController;

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

    _pages = <Widget>[MapPersistentPage(), LoginWidget()];
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            getIt<LocationProvider>().lastLocationInfo())
        .data;
    print((position?.position.toString() ?? "null") +
        " " +
        (position?.servicesEnabled.toString() ?? "boh") +
        " " +
        (position?.permissionGranted.toString() ?? "boh"));

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
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
                  )),
              BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: "User")
                ],
                currentIndex: _pageIndex,
                onTap: (i) => setState(() {
                  _pageController.jumpToPage(i);
                  _pageIndex = i;
                }),
                elevation: 0,
              )
            ],
          )),
      floatingActionButton: (_pageIndex != 0 || position?.position == null)
          ? null
          : FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
    );
  }
}
