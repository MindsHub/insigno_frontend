import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/page/introduction_page.dart';
import 'package:insigno_frontend/page/settings/about_card_widget.dart';
import 'package:insigno_frontend/page/settings/server_host_widget.dart';
import 'package:insigno_frontend/page/settings/switch_widget.dart';
import 'package:insigno_frontend/page/util/accept_to_review_dialog.dart';
import 'package:insigno_frontend/provider/verify_time_provider.dart';

class SettingsPage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = "/settingsPage";

  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with GetItStateMixin<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                get<Authentication>().isLoggedIn())
            .data ??
        get<Authentication>().isLoggedIn();

    final verifyTime = watchStream((VerifyTimeProvider provider) => provider.getVerifyTimeStream(),
                get<VerifyTimeProvider>().getVerifyTime())
            .data ??
        get<VerifyTimeProvider>().getVerifyTime();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AboutCardWidget(
                description: l10n.insignoDescription,
                svgAssetPath: "assets/icons/insigno_logo.svg",
                urlString: "https://github.com/MindsHub/insigno_frontend.git",
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AboutCardWidget(
                description: l10n.mindshubDescription,
                svgAssetPath: "assets/icons/mindshub_logo.svg",
                urlString: "https://mindshub.it",
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            if (isLoggedIn)
              SwitchWidget(
                checked: verifyTime.dateTime != null,
                title: l10n.acceptToReviewSwitchTitle,
                description: l10n.acceptToReviewSwitchDescription,
                onCheckedChanged: (acceptedToReview) async {
                  if (acceptedToReview) {
                    var confirmed = await openAcceptToReviewDialog(context);
                    if (confirmed != true) {
                      return;
                    }
                  }

                  await get<Backend>().setAcceptedToReview(acceptedToReview);
                  get<VerifyTimeProvider>().onAcceptedToReviewSettingChanged(acceptedToReview);
                },
              ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, IntroductionPage.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.replayIntroduction),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ServerHostWidget(),
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
