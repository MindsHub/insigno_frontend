import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../networking/data/pill.dart';

class PillPage extends StatelessWidget {
  static const routeName = '/pillPage';

  final Pill pill;

  const PillPage(this.pill, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pill)),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(pill.text, textAlign: TextAlign.center),
                const SizedBox(
                  height: 8,
                  width: double.infinity, // to make the column have maximum width
                ),
                Text(pill.author, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
                if (pill.source.isNotEmpty) const SizedBox(height: 12),
                if (pill.source.isNotEmpty)
                  InkWell(
                    onTap: () => launchUrlString(pill.source),
                    child: Text(
                      pill.source,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
