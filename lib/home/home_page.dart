import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/home/pill_page.dart';
import 'package:insigno_frontend/home/settings_page.dart';
import 'package:insigno_frontend/map/map_persistent_page.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/user/profile_persistent_page.dart';

import '../networking/data/pill.dart';

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

    // ignore any error that may occur while loading the pill
    get<Backend>().loadRandomPill().then((value) => setState(() {
          pill = value;
          pillAnimationController.forward();
        }));

    _tabs = <Widget>[ProfilePersistentPage(), MapPersistentPage(), SettingsPage()];
    _tabController = TabController(initialIndex: 1, length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {})); // <- notify when
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
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
                    child: InkWell(
                      onTap: () {
                        if (pill != null) {
                          Navigator.pushNamed(context, PillPage.routeName, arguments: pill);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
                        child: Text(pill?.text ?? "", textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => pillAnimationController.reverse(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),
            BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.user),
                BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.map),
                BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.settings)
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
