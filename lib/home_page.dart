import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/login_widget.dart';
import 'package:insignio_frontend/map/map_widget.dart';
import 'package:insignio_frontend/networking/extractor.dart';

import 'di/setup.dart';
import 'map/location.dart';

class HomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with GetItStateMixin<HomePage>, SingleTickerProviderStateMixin {
  int _pageIndex = 0;
  final List<Widget> _pages = <Widget>[MapWidget(), LoginWidget()];
  final List<String> _pageNames = ["Insignio", "Login to Insignio"];

  @override
  void initState() {
    super.initState();
    loadRandomPill().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(days: 36500), showCloseIcon: true, content: Text(value.text)));
    });
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
      appBar: AppBar(title: Text(_pageNames[_pageIndex])),
      body: _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "User")
        ],
        currentIndex: _pageIndex,
        onTap: (i) => setState(() => _pageIndex = i),
      ),
      floatingActionButton: (_pageIndex != 0 || position?.position == null)
          ? null
          : FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
    );
  }
}
