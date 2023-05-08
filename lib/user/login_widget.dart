import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/util/error_text.dart';

import '../networking/error.dart';

class LoginWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function() switchToSignupCallback;
  final bool justRegistered;

  LoginWidget(this.switchToSignupCallback, this.justRegistered, {super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with GetItStateMixin<LoginWidget> {
  String? email;
  String? password;
  bool loading = false;
  String? loginError;
  bool formatLoginError = true;

  final formKey = GlobalKey<FormState>();

  void performLogin() async {
    setState(() {
      loginError = null;
      loading = true;
    });

    get<Authentication>().login(email!, password!).then((_) {
      // if login has succeeded, whoever instantiated this widget will know about it thanks to
      // Authentication's isLoggedInStream
    }, onError: (e) {
      setState(() {
        if (e is UnauthorizedException && e.response.isNotEmpty) {
          loginError = e.response;
          formatLoginError = false;
        } else {
          loginError = e.toString();
          formatLoginError = true;
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
                if (widget.justRegistered)
                  Text(
                    l10n.confirmEmail,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                if (widget.justRegistered) const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.email),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return l10n.insertEmail;
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
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                ),
                ErrorText(
                  loginError,
                  formatLoginError ? l10n.wrongUserOrPassword : (v) => v,
                  topPadding: 16,
                ),
                const SizedBox(height: 16),
                loading
                    ? const CircularProgressIndicator()
                    : FloatingActionButton(
                        onPressed: () {
                          setState(() => loginError = null);
                          if (formKey.currentState?.validate() ?? false) {
                            formKey.currentState?.save();
                            TextInput.finishAutofillContext();
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
      ),
    );
  }
}
