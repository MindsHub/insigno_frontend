import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';

class SignupWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function() switchToLoginCallback;

  SignupWidget(this.switchToLoginCallback, {super.key});

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> with GetItStateMixin<SignupWidget> {
  String? username;
  String? password;
  bool loading = false;
  String? signupError;

  final firstPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void performSignup() async {
    setState(() {
      signupError = null;
      loading = true;
    });

    get<Authentication>().signup(username, password).then((_) {
      // if registration has succeeded, whoever instantiated this widget will know about it thanks
      // to Authentication's isLoggedInStream
    }, onError: (e) {
      setState(() {
        signupError = e.toString();
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(l10n.signup, style: theme.textTheme.headlineMedium),
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
              if (signupError != null)
                Text(
                  l10n.signupFailed,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              if (signupError != null)
                Text(
                  signupError!,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              loading
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();
                          performSignup();
                        }
                      },
                      tooltip: l10n.signup,
                      child: const Icon(Icons.login),
                    ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
