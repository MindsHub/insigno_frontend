import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/user/login_widget.dart';
import 'package:insigno_frontend/user/register_widget.dart';

class UserPersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  UserPersistentPage({super.key});

  @override
  State<UserPersistentPage> createState() => _UserPersistentPageState();
}

class _UserPersistentPageState extends State<UserPersistentPage>
    with AutomaticKeepAliveClientMixin<UserPersistentPage>, GetItStateMixin<UserPersistentPage> {
  bool loginOrRegister = true; // start with login

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
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => get<Authentication>().logout(),
            child: Text(l10n.logout),
          ),
        ),
      );
    } else if (loginOrRegister) {
      return LoginWidget(() => setState(() => loginOrRegister = false));
    } else {
      return RegisterWidget(() => setState(() => loginOrRegister = true));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
