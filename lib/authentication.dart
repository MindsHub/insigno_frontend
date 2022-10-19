import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_keys.dart';
import 'networking/const.dart';
String? token;

Future<bool> tryToLogin(String? username, String? password) async {
  final response = await http.post(
    Uri.parse(insigno_server+'/auth-token/'),
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
  token = authToken;
  return true;
}

Future<String> getToken() async {
  if (token == null) {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(AUTH_TOKEN);
  }

  if (token == null) {
    return "";
  } else {
    return token!;
  }
}

Future<String> getAuthorizationHeader() async {
  return "Token " + await getToken();
}

Future<dynamic> fetchJsonAuthenticated(Uri uri) async {
  final response = await http.get(
    uri,
    headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": await getAuthorizationHeader(),
    },
  );

  return jsonDecode(response.body);
}
