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
  String? errorMessage;
  bool isVersionCompatible = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // check whether this version of insigno is compatible with the backend, ignoring any errors
    get<Backend>().isCompatible().then((value) {
      isVersionCompatible = value;
      _updateError();
    }, onError: (e) => debugPrint("Could not check whether this version is compatible: $e"));

    get<LocationProvider>().getLocationStream().forEach((_) => _updateError());
    get<Authentication>().getIsLoggedInStream().forEach((_) => _updateError());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final isLoggedIn = watchStream(
            (Authentication authentication) => authentication.getIsLoggedInStream(),
            get<Authentication>().isLoggedIn())
        .data;

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
              child: AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                initialItemCount: (errorMessage == null ? 0 : 1) + 1,
                itemBuilder: _buildMessage,
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

  void _updateError() {
    final l10n = AppLocalizations.of(context)!;

    final prevErrorMessage = errorMessage;
    if (isVersionCompatible) {
      errorMessage = getErrorMessage(
          l10n, get<Authentication>().isLoggedIn(), get<LocationProvider>().lastLocationInfo());
    } else {
      errorMessage = l10n.oldVersion;
    }

    if (errorMessage != prevErrorMessage) {
      if (prevErrorMessage != null) {
        _listKey.currentState!.removeItem(
            0, (context, animation) => _buildErrorMessage(context, animation, prevErrorMessage));
      }
      if (errorMessage != null) {
        _listKey.currentState!.insertItem(0);
      }
    }
  }

  Widget _buildMessage(BuildContext context, int index, Animation<double> animation) {
    if (errorMessage != null && index == 0) {
      return _buildErrorMessage(context, animation, errorMessage!);
    } else {
      return _buildReviewMessage(context, animation);
    }
  }

  Widget _buildErrorMessage(BuildContext context, Animation<double> animation, String message) {
    final theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: animation,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            message,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.3,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewMessage(BuildContext context, Animation<double> animation) {
    final theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: animation,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              "Review in 14 minutes!",
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.3,
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
