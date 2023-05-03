import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/home/error_page.dart';
import 'package:insigno_frontend/home/home_page.dart';
import 'package:insigno_frontend/home/pill_page.dart';
import 'package:insigno_frontend/marker/marker_page.dart';
import 'package:insigno_frontend/marker/report_page.dart';
import 'package:insigno_frontend/marker/resolve_page.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/pill.dart';
import 'package:insigno_frontend/user/user_page.dart';

class InsignoApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const InsignoApp(this.navigatorKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        title: "Insigno",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic ??
              ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic ??
              ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        ),
        home: HomePage(),
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            ReportPage.routeName: (ctx) => ReportPage(),
            MarkerPage.routeName: (ctx) => MarkerPage(settings.arguments as MarkerPageArgs),
            ResolvePage.routeName: (ctx) => ResolvePage(settings.arguments as MapMarker),
            PillPage.routeName: (ctx) => PillPage(settings.arguments as Pill),
            UserPage.routeName: (ctx) => UserPage(settings.arguments as int),
            ErrorPage.routeName: (ctx) => ErrorPage(settings.arguments as FlutterErrorDetails)
          };
          WidgetBuilder builder = routes[settings.name]!;
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    });
  }
}
