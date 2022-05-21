import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_keys.dart';

Future<bool> tryToLogin(String? username, String? password) async {
  final response = await http.post(
    Uri.parse('http://insignio.mindshub.it/auth-token/'),
    body: jsonEncode({"username": username, "password": password}),
    headers: {
      "content-type": "application/json",
      "accept": "application/json",
    },
  );

  final authToken = jsonDecode(response.body)["token"];
  if (authToken == null) {
    return false;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AUTH_TOKEN, authToken);
  return true;
}