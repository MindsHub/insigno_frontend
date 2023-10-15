import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/page/user/change_password_page.dart';
import 'package:insigno_frontend/page/verification/image_review_page.dart';
import 'package:insigno_frontend/provider/auth_user_provider.dart';
import 'package:insigno_frontend/provider/verify_time_provider.dart';
import 'package:insigno_frontend/util/error_text.dart';

class ProfilePage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = "/profilePage";

  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin<ProfilePage>, GetItStateMixin<ProfilePage> {
  final pillFormKey = GlobalKey<FormState>();
  String pillText = "";
  String pillSource = "";
  bool pillLoading = false;
  String? pillError;
  bool pillSentAtLeastOnce = false;
  String? pillSourceError;
  late AnimationController pillAnim;
  bool changePasswordRequestSent = false;
  bool deleteAccountRequestSent = false;

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
    final user = watchStream(
                (AuthUserProvider userProv) => userProv.getAuthenticatedUserStream(),
                get<AuthUserProvider>().getAuthenticatedUserOrNull() ??
                    AuthenticatedUser(-1, "", double.negativeInfinity, false, "", null))
            .data ??
        AuthenticatedUser(-1, "", double.negativeInfinity, false, "", null);

    final verifyTime = watchStream((VerifyTimeProvider provider) => provider.getVerifyTimeStream(),
                get<VerifyTimeProvider>().getVerifyTime())
            .data ??
        get<VerifyTimeProvider>().getVerifyTime();

    return Scaffold(
      appBar: AppBar(title: Text(user.points == double.negativeInfinity ? l10n.user : user.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (changePasswordRequestSent
                    ? <Widget>[
                        Text(
                          l10n.confirmPasswordChange,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                      ]
                    : <Widget>[]) +
                (deleteAccountRequestSent
                    ? <Widget>[
                        Text(
                          l10n.confirmAccountDeletion,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                      ]
                    : <Widget>[]) +
                (user.points == double.negativeInfinity
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
                  const SizedBox(
                    height: 12,
                    width: double.infinity, // to make the column have maximum width
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, ChangePasswordPage.routeName)
                            .then((changeRequestSent) {
                          if (changeRequestSent is bool && changeRequestSent) {
                            setState(() {
                              changePasswordRequestSent = true;
                            });
                          }
                        }),
                        child: Text(l10n.changePassword),
                      ),
                      TextButton(
                        onPressed: () => openDeleteAccountDialog(l10n, context)
                            .then((accountDeletionRequested) {
                          if (accountDeletionRequested == true) {
                            get<Backend>().deleteAccount();
                            setState(() {
                              deleteAccountRequestSent = true;
                            });
                          }
                        }),
                        child: Text(l10n.deleteAccount),
                      ),
                      TextButton(
                        onPressed: () {
                          getIt<Authentication>().logout();
                          Navigator.pop(context);
                        },
                        child: Text(l10n.logout),
                      ),
                    ],
                  ),
                  if (user.isAdmin && verifyTime.dateTime != null)
                    const Divider(height: 32, thickness: 1),
                  if (user.isAdmin && verifyTime.dateTime != null)
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, ImageReviewPage.routeName),
                      child: Text(l10n.reviewImagesAsAdmin),
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
                          ErrorText(pillError, l10n.errorSendingPill, topPadding: 16),
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
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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

  Future<bool?> openDeleteAccountDialog(AppLocalizations l10n, BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountDeletionDialogTitle),
        content: SingleChildScrollView(
          child: Text(l10n.accountDeletionDialogText),
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
      ),
    );
  }
}
