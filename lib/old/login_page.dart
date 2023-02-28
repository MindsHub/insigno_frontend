import 'package:flutter/material.dart';
import 'authentication.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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

    tryToLogin(username, password).then((value) {
      if (value) {
        Navigator.pop(context);
      } else {
        setState(() {
          loginFailed = true;
          loading = false;
        });
      }
    });
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 60),
                      TextFormField(
                        initialValue: "john@gmail.com",
                        decoration: const InputDecoration(labelText: "Email"),
                        onSaved: (value) => username = value,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        initialValue: "NiceDoggo1",
                        decoration: const InputDecoration(labelText: "Password"),
                        onSaved: (value) => password = value,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        loginFailed ? "Wrong user or password" : "",
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 30),
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
                ))));
  }
}
