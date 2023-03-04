import 'package:flutter/material.dart';
import 'package:insignio_frontend/home_page.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:insignio_frontend/marker/marker_page.dart';
import 'package:insignio_frontend/marker/report_page.dart';

class InsignioApp extends StatelessWidget {
  const InsignioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        title: "Insignio",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic ?? ColorScheme.fromSwatch(brightness: Brightness.light)
        ),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic ?? ColorScheme.fromSwatch(brightness: Brightness.dark)
        ),
        home: HomePage(),
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            ReportPage.routeName: (ctx) => ReportPage(),
            MarkerPage.routeName: (ctx) => MarkerPage(settings.arguments as MarkerPageArgs),
          };
          WidgetBuilder builder = routes[settings.name]!;
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
      );
    });
  }
}
