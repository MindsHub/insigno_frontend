import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/util/error_text.dart';

class LoginWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function() switchToSignupCallback;

  LoginWidget(this.switchToSignupCallback, {super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with GetItStateMixin<LoginWidget> {
  String? name;
  String? password;
  bool loading = false;
  String? loginError;

  final formKey = GlobalKey<FormState>();

  void performLogin() async {
    setState(() {
      loginError = null;
      loading = true;
    });

    get<Authentication>().login(name!, password!).then((_) {
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: l10n.name),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.insertName;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => name = value,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.password),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.insertPassword;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => password = value,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              ErrorText(loginError, l10n.wrongUserOrPassword, spaceAbove: 16),
              const SizedBox(height: 16),
              loading
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: () {
                        setState(() => loginError = null);
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();
                          performLogin();
                        }
                      },
                      tooltip: l10n.login,
                      child: const Icon(Icons.login),
                    ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.notHaveAccount),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: widget.switchToSignupCallback,
                    child: Text(l10n.signup),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
