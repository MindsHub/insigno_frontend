import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';

class RegisterWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function() switchToLoginCallback;

  RegisterWidget(this.switchToLoginCallback, {super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> with GetItStateMixin<RegisterWidget> {
  String? username;
  String? password;
  bool loading = false;
  String? registrationError;

  final firstPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void performRegistration() async {
    setState(() {
      registrationError = null;
      loading = true;
    });

    get<Authentication>().signup(username, password).then((_) {
      // if registration has succeeded, whoever instantiated this widget will know about it thanks
      // to Authentication's isLoggedInStream
    }, onError: (e) {
      setState(() {
        registrationError = e.toString();
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
              Text(l10n.register, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.email),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.insertValidEmail;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => username = value,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: firstPasswordController,
                decoration: InputDecoration(labelText: l10n.password),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.insertGoodPassword;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => password = value,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.repeatPassword),
                validator: (value) {
                  if (value != firstPasswordController.value.text) {
                    return l10n.passwordsNotMatch;
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (registrationError != null)
                Text(
                  l10n.registrationFailed,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              if (registrationError != null)
                Text(
                  registrationError!,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              loading
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();
                          performRegistration();
                        }
                      },
                      tooltip: l10n.register,
                      child: const Icon(Icons.login),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.alreadyHaveAccount),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: widget.switchToLoginCallback,
                    child: Text(l10n.login),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
