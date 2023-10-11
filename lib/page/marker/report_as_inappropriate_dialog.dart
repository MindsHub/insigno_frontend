import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportAsInappropriateDialog extends StatelessWidget {
  const ReportAsInappropriateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l10n.confirmReportAsInappropriate,
                textAlign: TextAlign.center,
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              overflowSpacing: 4,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.ok),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
