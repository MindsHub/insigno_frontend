import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@module
abstract class ClientModule {
  @LazySingleton(dispose: disposeClient)
  http.Client get httpClient => http.Client();
}

void disposeClient(final http.Client instance) {
  instance.close();
}
