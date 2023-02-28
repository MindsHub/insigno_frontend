import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/authentication.dart';
import 'package:insignio_frontend/di/setup.dart';

class LoginWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with GetItStateMixin<LoginWidget> {
  String? username;
  String? password;
  bool loading = false;
  bool loginFailed = false;

  final formKey = GlobalKey<FormState>();

  void performLogin() async {
    setState(() {
      loginFailed = false;
      loading = true;
    });

    getIt<Authentication>().tryToLogin(username, password).then((success) {
      // if login has succeeded, whoever instantiated this widget will know about it thanks to
      // Authentication's isLoggedInStream
      if (!success) {
        setState(() {
          loginFailed = true;
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    initialValue: "john@gmail.com",
                    decoration: const InputDecoration(labelText: "Email"),
                    onSaved: (value) => username = value,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: "NiceDoggo1",
                    decoration: const InputDecoration(labelText: "Password"),
                    onSaved: (value) => password = value,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  if (loginFailed) const Text(
                    "Wrong user or password",
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  loading
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: () {
                            formKey.currentState?.save();
                            performLogin();
                          },
                          child: const Icon(Icons.login),
                        )
                ],
              ),
            )));
  }
}
