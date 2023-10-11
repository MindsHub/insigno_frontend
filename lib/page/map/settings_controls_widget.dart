import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/page/settings/settings_page.dart';

class SettingsControlsWidget extends StatelessWidget {
  final VoidCallback onFilterPressed;

  const SettingsControlsWidget(this.onFilterPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 8 + MediaQuery.of(context).padding.left,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FloatingActionButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              heroTag: "settings",
              onPressed: () => Navigator.pushNamed(context, SettingsPage.routeName),
              tooltip: l10n.settings,
              mini: true,
              child: const Icon(Icons.settings),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FloatingActionButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              heroTag: "filter",
              onPressed: onFilterPressed,
              tooltip: l10n.filterMarkers,
              mini: true,
              child: const Icon(Icons.filter_alt),
            ),
          ),
        ],
      ),
    );
  }
}
