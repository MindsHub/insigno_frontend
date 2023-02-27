import 'package:flutter/material.dart';
import 'package:insignio_frontend/map/map_page.dart';
import 'package:dynamic_color/dynamic_color.dart';

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
        home: MapPage(),
      );
    });
  }
}
