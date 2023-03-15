import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/authenticated_user.dart';
import 'package:insigno_frontend/user/user_provider.dart';

import '../networking/authentication.dart';

class UserWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  UserWidget({Key? key}) : super(key: key);

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget>
    with SingleTickerProviderStateMixin<UserWidget>, GetItStateMixin<UserWidget> {
  static final urlPattern = RegExp(
    r"(https?|http)://([-A-Z\d.]+)(/[-A-Z\d+&@#/%=~_|!:,.;]*)?(\?[A-Z\d+&@#/%=~_|!:,.;]*)?",
    caseSensitive: false,
  );

  final pillFormKey = GlobalKey<FormState>();
  String pillText = "";
  String pillSource = "";
  bool pillLoading = false;
  String? pillError;
  bool pillSentAtLeastOnce = false;
  late AnimationController pillAnim;

  @override
  void initState() {
    super.initState();
    pillAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    getIt<UserProvider>().requestAuthenticatedUser();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // double.negativeInfinity is used just to signal that the user has not loaded yet
    final user = watchStream((UserProvider userProv) => userProv.getAuthenticatedUserStream(),
                AuthenticatedUser("", double.negativeInfinity))
            .data ??
        AuthenticatedUser("", double.negativeInfinity);

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
                SizeTransition(
                  sizeFactor: pillAnim,
                  child: Form(
                    key: pillFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.pill,
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
                            if ((value?.isNotEmpty ?? false) && !urlPattern.hasMatch(value!)) {
                              return l10n.insertValidUrl;
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => pillSource = value ?? "",
                        ),
                        const SizedBox(height: 12),
                        if (pillError != null)
                          Text(
                            pillError!,
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 12),
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
                  ElevatedButton(
                    onPressed: () {
                      if (pillAnim.isDismissed) {
                        pillAnim.forward();
                        pillFormKey.currentState?.reset();
                      } else if (pillAnim.isCompleted &&
                          (pillFormKey.currentState?.validate() ?? false)) {
                        pillFormKey.currentState?.save();
                        submitPill();
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
      ),
    );
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
