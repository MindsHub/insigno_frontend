import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/user/login_widget.dart';
import 'package:insigno_frontend/user/signup_widget.dart';
import 'package:insigno_frontend/user/user_widget.dart';

class UserPersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  UserPersistentPage({super.key});

  @override
  State<UserPersistentPage> createState() => _UserPersistentPageState();
}

class _UserPersistentPageState extends State<UserPersistentPage>
    with AutomaticKeepAliveClientMixin<UserPersistentPage>, GetItStateMixin<UserPersistentPage> {
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
            ? const UserWidget()
            : loginOrSignup
                ? LoginWidget(() => setState(() => loginOrSignup = false))
                : SignupWidget(() => setState(() => loginOrSignup = true)),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
