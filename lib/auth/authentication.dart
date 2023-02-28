import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:insignio_frontend/pref/preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../networking/const.dart';

@lazySingleton
class Authentication {
  String? _cookie;
  final SharedPreferences _preferences;

  Authentication(this._preferences) : _cookie = _preferences.getString(authCookieKey);

  Future<bool> tryToLogin(String? email, String? password) async {
    final response = await http.post(
      Uri.parse(insignioServer + '/login/'),
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
    return true;
  }

  String? maybeCookie() {
    return _cookie;
  }

  String getCookie() {
    if (_cookie == null) {
      throw NotAuthenticatedException();
    } else {
      return _cookie!;
    }
  }
}

class NotAuthenticatedException {}