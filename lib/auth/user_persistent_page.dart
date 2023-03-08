import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/authentication.dart';
import 'package:insignio_frontend/auth/login_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserPersistentPage extends StatefulWidget with GetItStatefulWidgetMixin {
  UserPersistentPage({super.key});

  @override
  State<UserPersistentPage> createState() => _UserPersistentPageState();
}

class _UserPersistentPageState extends State<UserPersistentPage>
    with AutomaticKeepAliveClientMixin<UserPersistentPage>, GetItStateMixin<UserPersistentPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
            .data ??
        false;

    return isLoggedIn
        ? Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => get<Authentication>().logout(),
                child: Text(l10n.logout),
              ),
            ),
          )
        : LoginWidget();
  }

  @override
  bool get wantKeepAlive => true;
}
