import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/user/login_widget.dart';
import 'package:insigno_frontend/user/profile_widget.dart';
import 'package:insigno_frontend/user/signup_widget.dart';

class ProfilePersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  ProfilePersistentPage({super.key});

  @override
  State<ProfilePersistentPage> createState() => _ProfilePersistentPageState();
}

class _ProfilePersistentPageState extends State<ProfilePersistentPage>
    with
        AutomaticKeepAliveClientMixin<ProfilePersistentPage>,
        GetItStateMixin<ProfilePersistentPage> {
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
            ? l10n.yourProfile
            : loginOrSignup
                ? l10n.loginToInsigno
                : l10n.signup),
      ),
      body: Center(
        child: isLoggedIn
            ? ProfileWidget()
            : loginOrSignup
                ? LoginWidget(() => setState(() => loginOrSignup = false))
                : SignupWidget(() => setState(() => loginOrSignup = true)),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
