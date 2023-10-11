import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/page/user/change_password_widget.dart';
import 'package:insigno_frontend/page/user/login_widget.dart';
import 'package:insigno_frontend/page/user/signup_widget.dart';

class LoginFlowPage extends StatefulWidget {
  static const routeName = "/loginFlowPage";

  const LoginFlowPage({super.key});

  @override
  State<LoginFlowPage> createState() => _LoginFlowPageState();
}

enum LoginFlowPages {
  login,
  signup,
  changePassword;
}

class _LoginFlowPageState extends State<LoginFlowPage> {
  LoginFlowPages pageToShow = LoginFlowPages.login; // start with login
  LoginFlowPages showMessageForCompletedPage = LoginFlowPages.login; // no message needs to be shown

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text(pageToShow == LoginFlowPages.login
            ? l10n.loginToInsigno
            : pageToShow == LoginFlowPages.signup
                ? l10n.signup
                : l10n.forgotPassword),
      ),
      body: Center(
        child: pageToShow == LoginFlowPages.login
            ? LoginWidget(
                () => setState(() => pageToShow = LoginFlowPages.signup),
                () => setState(() => pageToShow = LoginFlowPages.changePassword),
                showMessageForCompletedPage,
              )
            : pageToShow == LoginFlowPages.signup
                ? SignupWidget((signupRequestSent) => setState(() {
                      pageToShow = LoginFlowPages.login;
                      if (signupRequestSent) {
                        showMessageForCompletedPage = LoginFlowPages.signup;
                      }
                    }))
                : ChangePasswordWidget((changeRequestSent) => setState(() {
                      pageToShow = LoginFlowPages.login;
                      if (changeRequestSent) {
                        showMessageForCompletedPage = LoginFlowPages.changePassword;
                      }
                    })),
      ),
    );
  }
}
