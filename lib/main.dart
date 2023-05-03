import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insigno_frontend/app.dart';
import 'package:insigno_frontend/di/setup.dart';

void main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
    runApp(const InsignoApp());
  }, (error, stack) {});
}
