import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/user/change_password_widget.dart';
import 'package:insigno_frontend/user/login_widget.dart';
import 'package:insigno_frontend/user/profile_widget.dart';
import 'package:insigno_frontend/user/signup_widget.dart';

class ProfilePersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  ProfilePersistentPage({super.key});

  @override
  State<ProfilePersistentPage> createState() => _ProfilePersistentPageState();
}

enum ProfilePages {
  login,
  signup,
  changePassword;
}

class _ProfilePersistentPageState extends State<ProfilePersistentPage>
    with
        AutomaticKeepAliveClientMixin<ProfilePersistentPage>,
        GetItStateMixin<ProfilePersistentPage> {
  ProfilePages pageToShow = ProfilePages.login; // start with login
  ProfilePages showMessageForCompletedPage = ProfilePages.login; // no message needs to be shown

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
      pageToShow = ProfilePages.login;
      showMessageForCompletedPage = ProfilePages.login;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isLoggedIn
            ? l10n.yourProfile
            : pageToShow == ProfilePages.login
                ? l10n.loginToInsigno
                : pageToShow == ProfilePages.signup
                    ? l10n.signup
                    : l10n.forgotPassword),
      ),
      body: Center(
        child: isLoggedIn
            ? ProfileWidget()
            : pageToShow == ProfilePages.login
                ? LoginWidget(
                    () => setState(() => pageToShow = ProfilePages.signup),
                    () => setState(() => pageToShow = ProfilePages.changePassword),
                    showMessageForCompletedPage,
                  )
                : pageToShow == ProfilePages.signup
                    ? SignupWidget((signupRequestSent) => setState(() {
                          pageToShow = ProfilePages.login;
                          if (signupRequestSent) {
                            showMessageForCompletedPage = ProfilePages.signup;
                          }
                        }))
                    : ChangePasswordWidget((changeRequestSent) => setState(() {
                          pageToShow = ProfilePages.login;
                          if (changeRequestSent) {
                            showMessageForCompletedPage = ProfilePages.changePassword;
                          }
                        })),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
