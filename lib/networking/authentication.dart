import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

@lazySingleton
class Authentication {
  final http.Client _client;
  final SharedPreferences _preferences;

  String? _cookie;
  final StreamController<bool> _streamController = StreamController.broadcast();

  Authentication(this._client, this._preferences)
      : _cookie = _preferences.getString(authCookieKey) {
    _streamController.add(isLoggedIn());
  }

  Future<bool> tryToLogin(String? email, String? password) async {
    final response = await _client.post(
      Uri(scheme: insignoServerScheme, host: insignoServer, path: "/login"),
      body: jsonEncode({"email": email, "password": password}),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    final authCookie = response.headers["set-cookie"]?.split("; ")[0];
    if (authCookie == null) {
      return false;
    }

    _cookie = authCookie;
    await _preferences.setString(authCookieKey, authCookie);
    _streamController.add(true);
    return true;
  }

  Future<void> removeStoredCookie() async {
    _streamController.add(false);
    _cookie = null;
    await _preferences.remove(authCookieKey);
  }

  Future<void> logout() async {
    // TODO send logout request
    await removeStoredCookie();
  }

  bool isLoggedIn() {
    return _cookie != null;
  }

  Stream<bool> getIsLoggedInStream() {
    return _streamController.stream;
  }

  String? maybeCookie() {
    return _cookie;
  }
}
