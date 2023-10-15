import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/user.dart';
import 'package:insigno_frontend/page/user/user_page.dart';
import 'package:insigno_frontend/util/future.dart';
import 'package:insigno_frontend/util/pair.dart';
import 'package:latlong2/latlong.dart';

class ScoreboardPage extends StatefulWidget {
  static const routeName = "/scoreboardPage";

  final LatLng mapCenter;

  const ScoreboardPage(this.mapCenter, {super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage>
    with SingleTickerProviderStateMixin<ScoreboardPage> {
  late TabController _tabController;
  List<User>? _scoreboard;
  String? _customTitle;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: _prevIndex);
    _onTabTap(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _customTitle == null || _tabController.index != 4 ? l10n.scoreboard : _customTitle!,
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabTap,
          tabs: [
            Tab(text: l10n.global),
            Tab(text: l10n.km1),
            Tab(text: l10n.km10),
            Tab(text: l10n.km100),
            const Tab(icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: _scoreboard == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          // if we are in the special tab, there is no custom title and the scoreboard is empty,
          // then it means that there is no active special scoreboard at the moment
          : _scoreboard?.isEmpty != false && _tabController.index == 4 && _customTitle == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noActiveSpecialScoreboard,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _scoreboard?.length ?? 0,
                  itemBuilder: (context, index) {
                    final user = _scoreboard?[index];
                    if (user == null) {
                      // should be unreachable
                      return const SizedBox();
                    }

                    return InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, UserPage.routeName, arguments: user.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            if (index == 0)
                              const Icon(Icons.looks_one, color: Color(0xffffd700))
                            else if (index == 1)
                              const Icon(Icons.looks_two, color: Color(0xffb0b0b0))
                            else if (index == 2)
                              const Icon(Icons.looks_3, color: Color(0xffcd7f32))
                            else
                              Container(
                                constraints: const BoxConstraints(minWidth: 24),
                                alignment: Alignment.center,
                                child: Text(
                                  (index + 1).toString(),
                                  textScaleFactor: 1.2,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.name,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Text(l10n.points(user.points)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _onTabTap(int index) {
    if (index == _prevIndex && _scoreboard != null) {
      return;
    }
    _prevIndex = index;

    setState(() {
      _scoreboard = null;
    });

    _getScoreboardFuture(index).then((value) {
      setState(() {
        _customTitle = value.first;
        _scoreboard ??= value.second;
      });
    }, onError: (e) {
      setState(() {
        _scoreboard ??= List.empty();
      });
      throw e;
    });
  }

  Future<Pair<String?, List<User>>> _getScoreboardFuture(int index) {
    final backend = getIt<Backend>();
    if (index == 0) {
      return backend.getGlobalScoreboard().map((e) => Pair(null, e));
    }
    if (index == 4) {
      return backend.getSpecialScoreboard();
    }

    double radius = index == 1
        ? 1000
        : index == 2
            ? 10000
            : 100000;
    return backend
        .getGeographicalScoreboard(
          widget.mapCenter.latitude,
          widget.mapCenter.longitude,
          radius,
        )
        .map((e) => Pair(null, e));
  }
}
