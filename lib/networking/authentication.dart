import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/networking/error.dart';
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

  Future<void> _loginOrSignup(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri(scheme: insignoServerScheme, host: insignoServer, path: path),
      body: jsonEncode(body),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    ).throwErrors();

    final authCookie = response.headers["set-cookie"]?.split("; ")[0];
    if (authCookie == null) {
      throw UnauthorizedException(401, "Missing token in response");
    }

    _cookie = authCookie;
    await _preferences.setString(authCookieKey, authCookie);
    _streamController.add(true);
  }

  Future<void> login(String? email, String? password) {
    return _loginOrSignup("/login", {"email": email, "password": password});
  }

  Future<void> signup(String? email, String? password) {
    return _loginOrSignup("/signup", {"email": email, "password": password});
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
