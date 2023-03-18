import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/pref/preferences_keys.dart';
import 'package:insigno_frontend/user/auth_user_provider.dart';
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
    _refreshToken(); // refresh token in the background
  }

  void _refreshToken() async {
    final cookie = _cookie;
    if (cookie == null) {
      return;
    }

    try {
      final response = await _client.post(
        Uri(scheme: insignoServerScheme, host: insignoServer, path: "/session"),
        headers: {"Cookie": cookie},
      );
      if (response.statusCode == 401) {
        // the token was outdated, ask the user to login again
        debugPrint("Cannot refresh outdated token");
        await removeStoredCookie();
      }
    } catch (e) {
      // ignore network errors
      debugPrint("Error when refreshing token: $e");
    }
  }

  Future<void> _loginOrSignup(String path, Map<String, String> body) async {
    final response = await _client
        .post(
          Uri(scheme: insignoServerScheme, host: insignoServer, path: path),
          body: body,
        );

    if (response.statusCode == 401) {
      throw UnauthorizedException(401, response.body);
    }
    response.throwErrors();

    final authCookie = response.headers["set-cookie"]?.split("; ")[0];
    if (authCookie == null) {
      throw UnauthorizedException(401, "Missing token in response");
    }

    _cookie = authCookie;
    await _preferences.setString(authCookieKey, authCookie);
    _streamController.add(true);
  }

  Future<void> login(String name, String password) {
    return _loginOrSignup("/login", {"name": name, "password": password});
  }

  Future<void> signup(String name, String password) {
    return _loginOrSignup("/signup", {"name": name, "password": password});
  }

  /// also invalidates the loaded user (if any) of [AuthUserProvider]
  Future<void> removeStoredCookie() async {
    try {
      getIt<AuthUserProvider>().invalidateLoadedUser();
    } on AssertionError catch (_) {
      // if Authentication depended on UserProvider, we would have a dependency cycle, therefore
      // we do not depend on it and we must allow it to not have registered/initialized yet
    }

    _streamController.add(false);
    _cookie = null;
    await _preferences.remove(authCookieKey);
  }

  /// also invalidates the loaded user (if any) of [AuthUserProvider]
  Future<void> logout() async {
    final cookie = _cookie;
    if (cookie == null) {
      return;
    }

    await _client.post(
      Uri(scheme: insignoServerScheme, host: insignoServer, path: "/logout"),
      headers: {"Cookie": cookie},
    );

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
