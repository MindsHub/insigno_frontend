import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/home/about_card_widget.dart';

class SettingsPage extends StatefulWidget with GetItStatefulWidgetMixin {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with GetItStateMixin<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8 + MediaQuery.of(context).padding.top, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AboutCardWidget(
              description: l10n.insignoDescription,
              svgAssetPath: "assets/icons/insigno_logo.svg",
            ),
            const SizedBox(height: 8),
            AboutCardWidget(
              description: l10n.mindshubDescription,
              svgAssetPath: "assets/icons/mindshub_logo.svg",
            ),
            if (kDebugMode) const SizedBox(height: 8),
            if (kDebugMode)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text("Crash sync"),
                    onPressed: () => throw Exception("Synccc"),
                  ),
                  TextButton(
                    child: const Text("Crash async"),
                    onPressed: () => Future.delayed(
                        const Duration(seconds: 0), () => throw Exception("Asynccc")),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
