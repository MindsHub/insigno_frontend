import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:insigno_frontend/app.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/page/error_page.dart';

void main() async {
  final navigatorKey = GlobalKey<NavigatorState>();
  var currentlyShowingError = false;
  reportError(FlutterErrorDetails e) {
    print(e.exception.runtimeType);
    print(e);
    Future.delayed(Duration.zero, () async {
      if (!currentlyShowingError) {
        currentlyShowingError = true;
        await navigatorKey.currentState?.pushNamed(ErrorPage.routeName, arguments: e).then((value) {
          currentlyShowingError = false;
        }, onError: (exception, stack) {
          currentlyShowingError = false;
        });
      }
    });
  }

  PlatformDispatcher.instance.onError = (exception, stack) {
    reportError(
        FlutterErrorDetails(exception: exception, stack: stack, library: "PlatformDispatcher"));
    return true;
  };

  runZonedGuarded(() async {
    FlutterError.onError = (FlutterErrorDetails e) {
      reportError(e.copyWith(library: "${e.library} - FlutterError during initialization"));
    };

    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails e) {
      reportError(e.copyWith(library: "${e.library} - FlutterError after initialization"));
    };

    await configureDependencies();

    runApp(InsignoApp(navigatorKey));
  }, (exception, stack) {
    reportError(FlutterErrorDetails(exception: exception, stack: stack, library: "Pure Dart"));
  });
}
