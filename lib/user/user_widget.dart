import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';

import '../networking/authentication.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({Key? key}) : super(key: key);

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  AuthenticatedUser? user;

  @override
  void initState() {
    super.initState();

    getIt<Backend>().getAuthenticatedUser().then((value) => setState(() => user = value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final logoutButton = ElevatedButton(
      onPressed: () => getIt<Authentication>().logout(),
      child: Text(l10n.logout),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: (user == null)
              ? [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  logoutButton,
                ]
              : [
                  Text(
                    user!.name,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.points(user!.points),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  logoutButton,
                ],
        ),
      ),
    );
  }
}
