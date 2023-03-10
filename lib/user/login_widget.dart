import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';

class LoginWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function() switchToRegisterCallback;

  LoginWidget(this.switchToRegisterCallback, {super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with GetItStateMixin<LoginWidget> {
  String? username;
  String? password;
  bool loading = false;
  String? loginError;

  final formKey = GlobalKey<FormState>();

  void performLogin() async {
    setState(() {
      loginError = null;
      loading = true;
    });

    get<Authentication>().login(username, password).then((_) {
      // if login has succeeded, whoever instantiated this widget will know about it thanks to
      // Authentication's isLoggedInStream
    }, onError: (e) {
      setState(() {
        loginError = e.toString();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(l10n.loginToInsigno, style: theme.textTheme.headlineMedium),
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
              if (loginError != null)
                Text(
                  l10n.wrongUserOrPassword,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              if (loginError != null)
                Text(
                  loginError!,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              loading
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: () {
                        formKey.currentState?.save();
                        performLogin();
                      },
                      tooltip: l10n.login,
                      child: const Icon(Icons.login),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.notHaveAccount),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: widget.switchToRegisterCallback,
                    child: Text(l10n.register),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}