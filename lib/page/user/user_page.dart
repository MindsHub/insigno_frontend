import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/user.dart';
import 'package:insigno_frontend/util/error_text.dart';

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
              children: ((user == null)
                  ? <Widget>[
                      if (error == null)
                        const CircularProgressIndicator()
                      else
                        ErrorText(error, l10n.errorLoading),
                    ]
                  : <Widget>[
                      Text(
                        user!.name,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 4,
                        width: double.infinity, // to make the column have maximum width
                      ),
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
