import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/provider/auth_user_provider.dart';
import 'package:insigno_frontend/page/user/validators.dart';
import 'package:insigno_frontend/util/error_text.dart';

class ChangePasswordWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final Function(bool changeRequestSent) finishCallback;

  ChangePasswordWidget(this.finishCallback, {super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget>
    with GetItStateMixin<ChangePasswordWidget> {
  String? email;
  String? password;
  bool loading = false;
  String? changePasswordError;
  bool formatChangePasswordError = true;

  late bool enableEmailField;
  final emailController = TextEditingController();
  final firstPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void performChangePassword() async {
    setState(() {
      changePasswordError = null;
      loading = true;
    });

    get<Authentication>().changePassword(email!, password!).then((_) {
      widget.finishCallback(true);
    }, onError: (e) {
      setState(() {
        if (e is UnauthorizedException && e.response.isNotEmpty) {
          changePasswordError = e.response;
          formatChangePasswordError = false;
        } else {
          changePasswordError = e.toString();
          formatChangePasswordError = true;
        }
        loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (get<Authentication>().isLoggedIn()) {
      enableEmailField = false;
      emailController.text = "...";
      get<AuthUserProvider>().requestAuthenticatedUser().then((user) {
        emailController.text = user.email;
      }, onError: (e) {
        setState(() {
          enableEmailField = true;
        });
      });
    } else {
      enableEmailField = true;
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
                  controller: emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                  validator: (value) => emailValidator(l10n, value),
                  onSaved: (value) => email = value,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  enabled: enableEmailField,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: firstPasswordController,
                  decoration: InputDecoration(labelText: l10n.newPassword),
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
                ),
                ErrorText(
                  changePasswordError,
                  formatChangePasswordError ? l10n.passwordChangeFailed : (v) => v,
                  topPadding: 16,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => widget.finishCallback(false),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 16),
                    loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              setState(() => changePasswordError = null);
                              if (formKey.currentState?.validate() ?? false) {
                                formKey.currentState?.save();
                                TextInput.finishAutofillContext();
                                performChangePassword();
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.send),
                                const SizedBox(width: 8),
                                const Icon(Icons.send),
                              ],
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.weWillSendEmail,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
