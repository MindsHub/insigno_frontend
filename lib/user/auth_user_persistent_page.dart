import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/user/auth_user_widget.dart';
import 'package:insigno_frontend/user/login_widget.dart';
import 'package:insigno_frontend/user/signup_widget.dart';

class AuthUserPersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  AuthUserPersistentPage({super.key});

  @override
  State<AuthUserPersistentPage> createState() => _AuthUserPersistentPageState();
}

class _AuthUserPersistentPageState extends State<AuthUserPersistentPage>
    with
        AutomaticKeepAliveClientMixin<AuthUserPersistentPage>,
        GetItStateMixin<AuthUserPersistentPage> {
  bool loginOrSignup = true; // start with login

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
            .data ??
        false;
    if (isLoggedIn) {
      // make sure the screen being shown after logout will be the login
      loginOrSignup = true;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isLoggedIn
            ? l10n.user
            : loginOrSignup
                ? l10n.loginToInsigno
                : l10n.signup),
      ),
      body: Center(
        child: isLoggedIn
            ? AuthUserWidget()
            : loginOrSignup
                ? LoginWidget(() => setState(() => loginOrSignup = false))
                : SignupWidget(() => setState(() => loginOrSignup = true)),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
