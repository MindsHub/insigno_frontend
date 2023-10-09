import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/networking/data/map_marker.dart';
import 'package:insigno_frontend/networking/data/pill.dart';
import 'package:insigno_frontend/page/error_page.dart';
import 'package:insigno_frontend/page/map/map_page.dart';
import 'package:insigno_frontend/page/marker/marker_page.dart';
import 'package:insigno_frontend/page/marker/report_page.dart';
import 'package:insigno_frontend/page/marker/resolve_page.dart';
import 'package:insigno_frontend/page/pill_page.dart';
import 'package:insigno_frontend/page/scoreboard/scoreboard_page.dart';
import 'package:insigno_frontend/page/settings/settings_page.dart';
import 'package:insigno_frontend/page/user/change_password_page.dart';
import 'package:insigno_frontend/page/verification/image_review_page.dart';
import 'package:insigno_frontend/page/user/login_flow_page.dart';
import 'package:insigno_frontend/page/user/profile_page.dart';
import 'package:insigno_frontend/page/user/user_page.dart';
import 'package:insigno_frontend/page/verification/image_verification_page.dart';
import 'package:latlong2/latlong.dart';

class InsignoApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const InsignoApp(this.navigatorKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final lightYellowTheme = ColorScheme.fromSeed(
      seedColor: Colors.yellow,
      brightness: Brightness.light,
    );
    final darkYellowTheme = ColorScheme.fromSeed(
      seedColor: Colors.yellow,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: "Insigno",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
          tertiaryContainer: lightYellowTheme.primaryContainer,
          onTertiaryContainer: lightYellowTheme.onPrimaryContainer,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          tertiaryContainer: darkYellowTheme.primaryContainer,
          onTertiaryContainer: darkYellowTheme.onPrimaryContainer,
        ),
      ),
      home: MapPage(),
      onGenerateRoute: (RouteSettings settings) {
        var routes = <String, WidgetBuilder>{
          ReportPage.routeName: (ctx) => ReportPage(),
          MarkerPage.routeName: (ctx) => MarkerPage(settings.arguments as MarkerPageArgs),
          ResolvePage.routeName: (ctx) => ResolvePage(settings.arguments as MapMarker),
          PillPage.routeName: (ctx) => PillPage(settings.arguments as Pill),
          UserPage.routeName: (ctx) => UserPage(settings.arguments as int),
          ErrorPage.routeName: (ctx) => ErrorPage(settings.arguments as FlutterErrorDetails),
          ImageReviewPage.routeName: (ctx) => const ImageReviewPage(),
          ChangePasswordPage.routeName: (ctx) => const ChangePasswordPage(),
          SettingsPage.routeName: (ctx) => const SettingsPage(),
          LoginFlowPage.routeName: (ctx) => const LoginFlowPage(),
          ProfilePage.routeName: (ctx) => ProfilePage(),
          ScoreboardPage.routeName: (ctx) => ScoreboardPage(settings.arguments as LatLng),
          ImageVerificationPage.routeName: (ctx) => ImageVerificationPage(),
        };
        WidgetBuilder builder = routes[settings.name]!;
        return MaterialPageRoute(builder: (ctx) => builder(ctx));
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
