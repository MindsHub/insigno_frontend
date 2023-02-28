import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insignio_frontend/auth/authentication.dart';
import 'package:insignio_frontend/auth/login_widget.dart';
import 'package:insignio_frontend/di/setup.dart';

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

    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                getIt<Authentication>().isLoggedIn())
            .data ??
        false;

    return isLoggedIn
        ? Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  getIt<Authentication>().logout();
                },
                child: Text("Logout".toUpperCase()),
              ),
            ),
          )
        : LoginWidget();
  }

  @override
  bool get wantKeepAlive => true;
}
