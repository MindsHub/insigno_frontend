import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:insigno_frontend/app.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/page/error_page.dart';
import 'package:insigno_frontend/page/util/error_snackbar_widget.dart';

void main() async {
  final navigatorKey = GlobalKey<NavigatorState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  var currentlyShowingError = false;
  reportError(FlutterErrorDetails e) {
    print(e.exception.runtimeType);
    print(e);
    Future.delayed(Duration.zero, () async {
      if (!currentlyShowingError) {
        currentlyShowingError = true;

        final future = scaffoldMessengerKey.currentState
                ?.showSnackBar(SnackBar(
                  content: ErrorSnackbarWidget(() {
                    scaffoldMessengerKey.currentState?.clearSnackBars();
                    navigatorKey.currentState?.pushNamed(ErrorPage.routeName, arguments: e);
                  }),
                  behavior: SnackBarBehavior.floating,
                  // the background color cannot be set from here since we don't have a `context`,
                  // so set a padding of 0 and let the ErrorSnackbarWidget draw the red background
                  padding: EdgeInsets.zero,
                ))
                .closed ??
            navigatorKey.currentState?.pushNamed(ErrorPage.routeName, arguments: e);

        await future?.then((_) {
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

    runApp(InsignoApp(navigatorKey, scaffoldMessengerKey));
  }, (exception, stack) {
    reportError(FlutterErrorDetails(exception: exception, stack: stack, library: "Pure Dart"));
  });
}
