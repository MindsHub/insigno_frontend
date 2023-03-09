import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/di/setup.config.dart';

// DI stands for Dependency Injection, hence the name of this module

final getIt = GetIt.instance;

@InjectableInit()
Future<GetIt> configureDependencies() => getIt.init();
