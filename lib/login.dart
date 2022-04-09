import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  String? username;
  String? password;
  final formKey = GlobalKey<FormState>();

  Login({Key? key}) : super(key: key);

  void performLogin() async {
    final response = await http.post(
      Uri.parse('http://insignio.mindshub.it/auth-token/'),
      body: jsonEncode({"username": username, "password": password}),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );

    print(jsonDecode(response.body)["token"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Login to Insignio!",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(height: 60),
                      TextFormField(
                        initialValue: "admin",
                        decoration:
                            const InputDecoration(labelText: "Username"),
                        onSaved: (value) => username = value,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        initialValue: "admin",
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        onSaved: (value) => password = value,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 60),
                      FloatingActionButton(
                        onPressed: () {
                          formKey.currentState?.save();
                          performLogin();
                        },
                        child: const Icon(Icons.login),
                      )
                    ],
                  ),
                ))));
  }
}
