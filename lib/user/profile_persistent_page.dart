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

enum _PageToShow {
  login,
  signup,
  forgotPassword;
}

class _ProfilePersistentPageState extends State<ProfilePersistentPage>
    with
        AutomaticKeepAliveClientMixin<ProfilePersistentPage>,
        GetItStateMixin<ProfilePersistentPage> {
  _PageToShow pageToShow = _PageToShow.login; // start with login
  bool justRegistered = false;

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
      pageToShow = _PageToShow.login;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isLoggedIn
            ? l10n.yourProfile
            : pageToShow == _PageToShow.login
                ? l10n.loginToInsigno
                : pageToShow == _PageToShow.signup
                    ? l10n.signup
                    : l10n.forgotPassword),
      ),
      body: Center(
        child: isLoggedIn
            ? ProfileWidget()
            : pageToShow == _PageToShow.login
                ? LoginWidget(() => setState(() => pageToShow = _PageToShow.signup),
                    () => setState(() => pageToShow = _PageToShow.forgotPassword), justRegistered)
                : pageToShow == _PageToShow.signup
                    ? SignupWidget((isJustRegistered) => setState(() {
                          pageToShow = _PageToShow.login;
                          justRegistered = isJustRegistered;
                        }))
                    : Placeholder(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
