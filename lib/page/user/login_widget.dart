import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/page/user/login_flow_page.dart';
import 'package:insigno_frontend/util/error_text.dart';

class LoginWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function() switchToSignupCallback;
  final Function() switchToForgotPasswordCallback;
  final LoginFlowPages showMessageForCompletedPage;

  LoginWidget(this.switchToSignupCallback, this.switchToForgotPasswordCallback,
      this.showMessageForCompletedPage,
      {super.key});

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
      // pop the login flow page
      Navigator.pop(context);
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

  void submitForm() {
    setState(() => loginError = null);
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      TextInput.finishAutofillContext();
      performLogin();
    }
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
                if (widget.showMessageForCompletedPage != LoginFlowPages.login)
                  Text(
                    widget.showMessageForCompletedPage == LoginFlowPages.signup
                        ? l10n.confirmEmail
                        : l10n.confirmPasswordChange,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                if (widget.showMessageForCompletedPage != LoginFlowPages.login)
                  const SizedBox(height: 16),
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
                  keyboardType: TextInputType.emailAddress,
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
                  onFieldSubmitted: (_) => submitForm(),
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
                        onPressed: submitForm,
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.switchToForgotPasswordCallback,
                  child: Text(l10n.forgotPassword),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
