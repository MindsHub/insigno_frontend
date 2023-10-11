import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool?> openAcceptToReviewDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(l10n.acceptToReviewDialogTitle),
        content: SingleChildScrollView(
          child: Text(l10n.acceptToReviewDialogText(l10n.yes)),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.yes),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text(l10n.no),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}