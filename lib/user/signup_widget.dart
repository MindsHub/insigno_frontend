import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/util/error_text.dart';

import '../networking/error.dart';

class SignupWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function(bool) switchToLoginCallback;

  SignupWidget(this.switchToLoginCallback, {super.key});

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> with GetItStateMixin<SignupWidget> {
  // taken from the HTML5 validation spec, except for the + at the end which used to be a *
  static final emailValidator = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)+$");
  static final nameValidator = RegExp(r'^[a-zA-Z0-9 _]*$');
  static final passwordValidator =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).*$');

  String? email;
  String? name;
  String? password;
  bool loading = false;
  String? signupError;
  bool formatSignupError = true;

  final firstPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void performSignup() async {
    setState(() {
      signupError = null;
      loading = true;
    });

    get<Authentication>().signup(email!, name!, password!).then((_) {
      widget.switchToLoginCallback(true);
    }, onError: (e) {
      setState(() {
        if (e is UnauthorizedException && e.response.isNotEmpty) {
          signupError = e.response;
          formatSignupError = false;
        } else {
          signupError = e.toString();
          formatSignupError = true;
        }
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: AutofillGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.email),
                  validator: (value) {
                    final v = value?.trim() ?? "";
                    if (v.isEmpty) {
                      return l10n.insertEmail;
                    } else if (!emailValidator.hasMatch(v)) {
                      return l10n.insertValidEmail;
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => email = value,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.name),
                  validator: (value) {
                    final v = value?.trim() ?? "";
                    if (v.isEmpty) {
                      return l10n.insertName;
                    } else if (v.length < 3 || v.length > 20) {
                      return l10n.invalidNameLength;
                    } else if (!nameValidator.hasMatch(v)) {
                      return l10n.invalidNameCharacters;
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => name = value,
                  autofillHints: const [AutofillHints.username],
                  maxLength: 20,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: firstPasswordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  validator: (value) {
                    final v = value ?? "";
                    if (v.isEmpty) {
                      return l10n.insertPassword;
                    } else if (v.length < 8) {
                      return l10n.invalidPasswordLength;
                    } else if (!passwordValidator.hasMatch(v)) {
                      return l10n.invalidPasswordCharacters;
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => password = value,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
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
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                ),
                ErrorText(
                  signupError,
                  formatSignupError ? l10n.signupFailed : (v) => v,
                  spaceAbove: 16,
                ),
                const SizedBox(height: 16),
                loading
                    ? const CircularProgressIndicator()
                    : FloatingActionButton(
                        onPressed: () {
                          setState(() => signupError = null);
                          if (formKey.currentState?.validate() ?? false) {
                            formKey.currentState?.save();
                            TextInput.finishAutofillContext();
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
                      onPressed: () => widget.switchToLoginCallback(false),
                      child: Text(l10n.login),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
