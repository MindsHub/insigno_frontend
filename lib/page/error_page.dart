import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorPage extends StatelessWidget {
  static const routeName = '/errorPage';

  final FlutterErrorDetails e;

  const ErrorPage(this.e, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final errorString = "${e.library}\n\n${e.exception}\n\n${e.stack}".trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ohNoError),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              child: Text(l10n.copy.toUpperCase()),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: errorString));
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              errorString,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}
