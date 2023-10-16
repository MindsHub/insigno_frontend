import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/page/user/validators.dart';
import 'package:insigno_frontend/util/error_text.dart';

class SignupWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function(bool signupRequestSent) switchToLoginCallback;

  SignupWidget(this.switchToLoginCallback, {super.key});

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> with GetItStateMixin<SignupWidget> {
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

  void submitForm() {
    setState(() => signupError = null);
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      TextInput.finishAutofillContext();
      performSignup();
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
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.email),
                  validator: (value) => emailValidator(l10n, value),
                  onSaved: (value) => email = value,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.name),
                  validator: (value) => nameValidator(l10n, value),
                  onSaved: (value) => name = value,
                  autofillHints: const [AutofillHints.username],
                  maxLength: 20,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: firstPasswordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  validator: (value) => passwordValidator(l10n, value),
                  onSaved: (value) => password = value,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(labelText: l10n.repeatPassword),
                  validator: (value) =>
                      repeatPasswordValidator(l10n, value, firstPasswordController.value.text),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => submitForm(),
                ),
                ErrorText(
                  signupError,
                  formatSignupError ? l10n.signupFailed : (v) => v,
                  topPadding: 16,
                ),
                const SizedBox(height: 16),
                loading
                    ? const CircularProgressIndicator()
                    : FloatingActionButton(
                        onPressed: submitForm,
                        tooltip: l10n.signup,
                        child: const Icon(Icons.login),
                      ),
                const SizedBox(height: 16),
                Text(
                  l10n.weWillSendEmail,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.alreadyHaveAccount),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => widget.switchToLoginCallback(false),
                      child: Text(l10n.login),
                    ),
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
