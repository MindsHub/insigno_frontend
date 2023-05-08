import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ServerHostHandler {
  static const _defaultScheme = "https";
  static const _defaultHost = "insigno.mindshub.it";

  final SharedPreferences _preferences;
  String _scheme;
  String _host;
  int? _port;
  final StreamController<String> _uriStringStreamController = StreamController.broadcast();

  ServerHostHandler(this._preferences)
      : _scheme = _preferences.getString(serverScheme) ?? _defaultScheme,
        _host = _preferences.getString(serverHost) ?? _defaultHost,
        _port = _preferences.getInt(serverPort) {
    _uriStringStreamController.add(getUri("").toString());
  }

  Uri getUri(String path, {Map<String, dynamic>? params}) {
    return Uri(
      scheme: _scheme,
      host: _host,
      port: _port,
      path: path,
      queryParameters: params,
    );
  }

  Future<void> setSchemeHost(String scheme, String host, int? port) async {
    if (scheme == _defaultScheme && host == _defaultHost) {
      return resetSchemeHost();
    }

    _scheme = scheme;
    _host = host;
    _port = port;
    _uriStringStreamController.add(getUri("").toString());
    await Future.wait([
      _preferences.setString(serverScheme, scheme),
      _preferences.setString(serverHost, host),
      if (port == null) _preferences.remove(serverPort) else _preferences.setInt(serverPort, port),
    ]);
  }

  Future<void> resetSchemeHost() async {
    _scheme = _defaultScheme;
    _host = _defaultHost;
    _port = null;
    _uriStringStreamController.add(getUri("").toString());
    await Future.wait([
      _preferences.remove(serverScheme),
      _preferences.remove(serverHost),
      _preferences.remove(serverPort),
    ]);
  }

  Stream<String> getUriStringStream() {
    return _uriStringStreamController.stream;
  }

  static String getDefaultUriString() {
    return Uri(scheme: _defaultScheme, host: _defaultHost).toString();
  }
}
