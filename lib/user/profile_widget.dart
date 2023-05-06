import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/user/auth_user_provider.dart';
import 'package:insigno_frontend/user/image_review_page.dart';
import 'package:insigno_frontend/util/error_text.dart';

import '../networking/authentication.dart';

class ProfileWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with SingleTickerProviderStateMixin<ProfileWidget>, GetItStateMixin<ProfileWidget> {
  final pillFormKey = GlobalKey<FormState>();
  String pillText = "";
  String pillSource = "";
  bool pillLoading = false;
  String? pillError;
  bool pillSentAtLeastOnce = false;
  String? pillSourceError;
  late AnimationController pillAnim;

  @override
  void initState() {
    super.initState();
    pillAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    getIt<AuthUserProvider>().requestAuthenticatedUser();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // double.negativeInfinity is used just to signal that the user has not loaded yet
    final user = watchStream((AuthUserProvider userProv) => userProv.getAuthenticatedUserStream(),
                AuthenticatedUser(-1, "", double.negativeInfinity, false))
            .data ??
        AuthenticatedUser(-1, "", double.negativeInfinity, false);

    final logoutButton = ElevatedButton(
      onPressed: () => getIt<Authentication>().logout(),
      child: Text(l10n.logout),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: ((user.points == double.negativeInfinity)
                  ? <Widget>[
                      const CircularProgressIndicator(),
                    ]
                  : <Widget>[
                      Text(
                        user.name,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.points(user.points),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ]) +
              <Widget>[
                const SizedBox(height: 12),
                logoutButton,
                const Divider(height: 32, thickness: 1),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, ImageReviewPage.routeName),
                  child: Text(l10n.reviewImages),
                ),
                const Divider(height: 32, thickness: 1),
                SizeTransition(
                  sizeFactor: pillAnim,
                  child: Form(
                    key: pillFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.infoText,
                            hintText: l10n.insertEcologyPill,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return l10n.insertPill;
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => pillText = value ?? "",
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.source,
                            hintText: l10n.insertPossiblySource,
                          ),
                          validator: (value) {
                            return pillSourceError;
                          },
                          onSaved: (value) => pillSource = value ?? "",
                        ),
                        ErrorText(pillError, l10n.errorSendingPill, spaceAbove: 16),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: ReverseAnimation(pillAnim),
                  child: pillSentAtLeastOnce
                      ? Center(
                          child: Text(
                            l10n.thanks,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox(),
                ),
                if (pillLoading)
                  const CircularProgressIndicator()
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizeTransition(
                        sizeFactor: pillAnim,
                        axis: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => pillAnim.reverse(),
                              child: Text(l10n.cancel),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (pillAnim.isDismissed) {
                            pillAnim.forward();
                            pillFormKey.currentState?.reset();
                            pillSourceError = null;
                          } else if (pillAnim.isCompleted) {
                            pillFormKey.currentState?.save();
                            pillSourceError = await getPillSourceError(l10n);
                            if (pillFormKey.currentState?.validate() ?? false) {
                              submitPill();
                            }
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.suggestPill),
                            SizeTransition(
                              sizeFactor: pillAnim,
                              axis: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(width: 8),
                                  Icon(Icons.send),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
        ),
      ),
    );
  }

  Future<String?> getPillSourceError(AppLocalizations l10n) async {
    if (pillSource.isEmpty) {
      return null;
    }

    final Uri uri;
    try {
      uri = Uri.parse(pillSource.contains("://") ? pillSource : "https://$pillSource");
    } on FormatException catch (_) {
      return l10n.insertValidUrl;
    }

    if (uri.scheme != "https") {
      return l10n.onlyHttpsAccepted;
    }

    setState(() {
      pillLoading = true;
    });
    try {
      await get<http.Client>() //
          .head(uri)
          .timeout(const Duration(seconds: 3))
          .throwErrors();
      setState(() {
        pillLoading = false;
      });
      return null;
    } on FormatException catch (_) {
      setState(() {
        pillLoading = false;
      });
      return l10n.insertValidUrl;
    } catch (e) {
      setState(() {
        pillLoading = false;
      });
      return e.toString();
    }
  }

  void submitPill() {
    setState(() {
      pillError = null;
      pillLoading = true;
    });

    getIt<Backend>().suggestPill(pillText, pillSource).then((_) {
      // pill uploaded successfully!
      pillAnim.reverse();
      setState(() {
        pillSentAtLeastOnce = true;
        pillLoading = false;
      });
    }, onError: (e) {
      setState(() {
        pillError = e.toString();
        pillLoading = false;
      });
    });
  }
}
