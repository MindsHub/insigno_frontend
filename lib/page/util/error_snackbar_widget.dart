import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorSnackbarWidget extends StatelessWidget {
  final void Function() onTap;

  const ErrorSnackbarWidget(this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      color: theme.colorScheme.errorContainer,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 14, left: 16, right: 8),
              child: Text(
                l10n?.errorOccurred ?? "An error occurred",
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
                maxLines: 2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              child: Text(
                (l10n?.reportError ?? "Report").toUpperCase(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
