import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/authentication.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    get<Authentication>().tryToLogin(username, password).then((success) {
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(l10n.loginToInsignio, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: "john@gmail.com",
                decoration: InputDecoration(labelText: l10n.email),
                onSaved: (value) => username = value,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: "NiceDoggo1",
                decoration: InputDecoration(labelText: l10n.password),
                onSaved: (value) => password = value,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (loginFailed)
                Text(
                  l10n.wrongUserOrPassword,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
        ));
  }
}
