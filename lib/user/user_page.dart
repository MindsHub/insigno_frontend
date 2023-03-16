import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';

import '../networking/data/user.dart';

class UserPage extends StatefulWidget {
  static const routeName = "/userPage";

  final int userId;

  const UserPage(this.userId, {Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? user;
  String? error;

  @override
  void initState() {
    super.initState();
    getIt<Backend>().getUser(widget.userId).then((value) => setState(() => user = value),
        onError: (e) => setState(() => error = e.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.user),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: ((user == null)
                  ? <Widget>[
                      if (error == null)
                        const CircularProgressIndicator()
                      else
                        Text(
                          error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                    ]
                  : <Widget>[
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
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}
