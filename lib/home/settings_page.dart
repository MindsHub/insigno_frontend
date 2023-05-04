import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

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
            Card(
              child: InkWell(
                onTap: () {},
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.insignoDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/insigno_logo.svg",
                        width: MediaQuery.of(context).size.width / 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: InkWell(
                onTap: () {},
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.mindshubDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/mindshub_logo.svg",
                        width: MediaQuery.of(context).size.width / 5,
                      ),
                    ],
                  ),
                ),
              ),
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
