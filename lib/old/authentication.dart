import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'preferences_keys.dart';
import 'networking/const.dart';

String? cookie;

Future<bool> tryToLogin(String? email, String? password) async {
  final response = await http.post(
    Uri.parse(insignio_server + '/login/'),
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

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AUTH_COOKIE, authCookie);
  cookie = authCookie;
  return true;
}

Future<String> getCookie() async {
  if (cookie == null) {
    final prefs = await SharedPreferences.getInstance();
    cookie = prefs.getString(AUTH_COOKIE);
  }

  if (cookie == null) {
    return "";
  } else {
    return cookie!;
  }
}

Future<dynamic> fetchJsonAuthenticated(Uri uri) async {
  final response = await http.get(
    uri,
    headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Cookie": await getCookie(),
    },
  );

  return jsonDecode(response.body);
}
