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

  ServerHostHandler(this._preferences)
      : _scheme = _preferences.getString(serverScheme) ?? _defaultScheme,
        _host = _preferences.getString(serverHost) ?? _defaultHost;

  Uri getUri(String path, {Map<String, dynamic>? params}) {
    return Uri(
      scheme: _scheme,
      host: _host,
      path: path,
      queryParameters: params,
    );
  }

  void setSchemeHost(String uriString) async {
    final uri = Uri.parse(uriString);
    _scheme = uri.scheme;
    _host = uri.host;
    await Future.wait([
      _preferences.setString(serverScheme, uri.scheme),
      _preferences.setString(serverHost, uri.host),
    ]);
  }

  void resetSchemeHost() async {
    _scheme = _defaultScheme;
    _host = _defaultHost;
    await Future.wait([
      _preferences.remove(serverScheme),
      _preferences.remove(serverHost),
    ]);
  }
}
