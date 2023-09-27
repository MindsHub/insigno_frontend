import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/page/map/location_provider.dart';
import 'package:insigno_frontend/page/user/login_flow_page.dart';
import 'package:insigno_frontend/page/user/profile_page.dart';
import 'package:insigno_frontend/util/error_messages.dart';

class BottomControlsWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final VoidCallback onAddWidgetPressed;

  BottomControlsWidget(this.onAddWidgetPressed, {super.key});

  @override
  State<BottomControlsWidget> createState() => _BottomControlsWidgetState();
}

class _BottomControlsWidgetState extends State<BottomControlsWidget>
    with GetItStateMixin<BottomControlsWidget>, TickerProviderStateMixin<BottomControlsWidget> {
  static const Duration errorMessageAnimDuration = Duration(milliseconds: 200);

  String lastErrorMessage = "";
  late final AnimationController errorMessageAnim;
  bool isVersionCompatible = true;

  @override
  void initState() {
    super.initState();

    errorMessageAnim = AnimationController(vsync: this, duration: errorMessageAnimDuration);

    // check whether this version of insigno is compatible with the backend, ignoring any errors
    get<Backend>().isCompatible().then((value) => setState(() => isVersionCompatible = value),
        onError: (e) => debugPrint("Could not check whether this version is compatible: $e"));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;
    final isLoggedIn = watchStream(
            (Authentication authentication) => authentication.getIsLoggedInStream(),
            get<Authentication>().isLoggedIn())
        .data;

    final String? errorMessage =
        isVersionCompatible ? getErrorMessage(l10n, isLoggedIn, position) : l10n.oldVersion;
    if (errorMessage == null) {
      errorMessageAnim.reverse();
    } else {
      lastErrorMessage = errorMessage;
      errorMessageAnim.forward();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16 + mediaQuery.padding.left,
        right: 16 + mediaQuery.padding.right,
        bottom: 16 + mediaQuery.padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "user",
            onPressed: isLoggedIn == null
                ? null
                : () => Navigator.pushNamed(
                    context, isLoggedIn == true ? ProfilePage.routeName : LoginFlowPage.routeName),
            tooltip: isLoggedIn == true ? l10n.user : l10n.login,
            child: isLoggedIn == true ? const Icon(Icons.person) : const Icon(Icons.login),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        errorMessage,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.3,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "addMarker",
            onPressed: errorMessage == null ? widget.onAddWidgetPressed : null,
            tooltip: l10n.report,
            backgroundColor:
                errorMessage == null ? null : theme.colorScheme.primaryContainer.withOpacity(0.38),
            foregroundColor: errorMessage == null
                ? null
                : theme.colorScheme.onPrimaryContainer.withOpacity(0.38),
            disabledElevation: 0,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
