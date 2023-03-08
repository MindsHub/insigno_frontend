import 'package:flutter/material.dart';
import 'package:insignio_frontend/app.dart';
import 'package:insignio_frontend/di/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const InsignioApp());
}
