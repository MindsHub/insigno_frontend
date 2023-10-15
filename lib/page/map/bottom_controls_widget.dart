import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/authentication.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/image_verification.dart';
import 'package:insigno_frontend/page/map/animated_message_box.dart';
import 'package:insigno_frontend/page/map/verify_message_box.dart';
import 'package:insigno_frontend/page/user/login_flow_page.dart';
import 'package:insigno_frontend/page/user/profile_page.dart';
import 'package:insigno_frontend/page/util/accept_to_review_dialog.dart';
import 'package:insigno_frontend/page/verification/image_verification_page.dart';
import 'package:insigno_frontend/provider/location_provider.dart';
import 'package:insigno_frontend/provider/verify_time_provider.dart';
import 'package:insigno_frontend/util/error_messages.dart';
import 'package:material_symbols_icons/symbols.dart';

class BottomControlsWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final VoidCallback onAddWidgetPressed;

  BottomControlsWidget(this.onAddWidgetPressed, {super.key});

  @override
  State<BottomControlsWidget> createState() => _BottomControlsWidgetState();
}

class _BottomControlsWidgetState extends State<BottomControlsWidget>
    with GetItStateMixin<BottomControlsWidget>, TickerProviderStateMixin<BottomControlsWidget> {
  ErrorMessage? errorMessage;
  bool isVersionCompatible = true;
  VerifyTime verifyTime = VerifyTime.notAcceptedYet(false);

  late final Timer appOpenedTimer;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // check whether this version of insigno is compatible with the backend, ignoring any errors
    get<Backend>().isCompatible().then((value) {
      isVersionCompatible = value;
      _updateErrorMessage();
    }, onError: (e) => debugPrint("Could not check whether this version is compatible: $e"));

    // show errors about the location being loaded only after 2 seconds since the app is started
    // to avoid useless appearing and disappearing popups
    appOpenedTimer = Timer(const Duration(seconds: 0), () {
      _updateErrorMessage();
    });

    _updateErrorMessage();
    _updateVerifyMessage(get<VerifyTimeProvider>().getVerifyTime());

    get<LocationProvider>().getLocationStream().forEach((_) => _updateErrorMessage());
    get<Authentication>().getIsLoggedInStream().forEach((_) => _updateErrorMessage());
    get<VerifyTimeProvider>()
        .getVerifyTimeStream()
        .forEach((newVerifyTime) => _updateVerifyMessage(newVerifyTime));

    // animation tests:
    //Timer.periodic(Duration(milliseconds: 1), (t) { print("c"); isVersionCompatible = !isVersionCompatible; _updateErrorMessage(); });
    //Timer.periodic(Duration(milliseconds: 500), (t) { print("a"); get<VerifyTimeProvider>().update(); });
    //Timer.periodic(Duration(milliseconds: 400), (t) { print("b"); get<VerifyTimeProvider>().onAcceptedToReviewSettingChanged(false); });
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
            child: isLoggedIn == true
                ? const Icon(Symbols.person_check)
                : const Icon(Symbols.person_alert),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedList(
                physics: const NeverScrollableScrollPhysics(),
                key: _listKey,
                shrinkWrap: true,
                initialItemCount:
                    (errorMessage != null ? 1 : 0) + (verifyTime.shouldShowMessage() ? 1 : 0),
                itemBuilder: _buildMessage,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "addMarker",
            onPressed: errorMessage == null ? widget.onAddWidgetPressed : null,
            tooltip: l10n.report,
            backgroundColor: errorMessage == null //
                ? null
                : theme.colorScheme.primaryContainer.withOpacity(0.38),
            foregroundColor: errorMessage == null //
                ? null
                : theme.colorScheme.onPrimaryContainer.withOpacity(0.38),
            disabledElevation: 0,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _updateErrorMessage() {
    final prevErrorMessage = errorMessage;
    ErrorMessage? newErrorMessage;
    if (isVersionCompatible) {
      newErrorMessage = getErrorMessage(
        get<Authentication>().isLoggedIn(),
        get<LocationProvider>().lastLocationInfo(),
      );

      if (appOpenedTimer.isActive && newErrorMessage == ErrorMessage.locationIsLoading) {
        // do not show "Location is loading" for the first two seconds, since it might load faster
        newErrorMessage = null;
      }
    } else {
      newErrorMessage = ErrorMessage.oldVersion;
    }

    if (_listKey.currentState != null && newErrorMessage != prevErrorMessage) {
      if (newErrorMessage != null) {
        _listKey.currentState!.insertItem(0);
      }
      if (prevErrorMessage != null) {
        _listKey.currentState!.removeItem(newErrorMessage == null ? 0 : 1,
            (context, animation) => _buildErrorMessage(context, animation, prevErrorMessage));
      }
    }
    setState(() {
      errorMessage = newErrorMessage;
    });
  }

  void _updateVerifyMessage(VerifyTime newVerifyTime) async {
    var oldVerifyTime = verifyTime;
    if (_listKey.currentState != null &&
        oldVerifyTime.shouldShowMessage() != newVerifyTime.shouldShowMessage()) {
      if (newVerifyTime.shouldShowMessage()) {
        _listKey.currentState!.insertItem(errorMessage == null ? 0 : 1);
      } else {
        _listKey.currentState!.removeItem(errorMessage == null ? 0 : 1,
            (context, animation) => _buildVerifyMessage(context, animation, oldVerifyTime));
      }
    }
    setState(() {
      verifyTime = newVerifyTime;
    });
  }

  Widget _buildMessage(BuildContext context, int index, Animation<double> animation) {
    if (errorMessage != null && index == 0) {
      return _buildErrorMessage(context, animation, errorMessage!);
    } else if (verifyTime.shouldShowMessage()) {
      return _buildVerifyMessage(context, animation, verifyTime);
    } else {
      // should be unreachable
      return const SizedBox.shrink();
    }
  }

  Widget _buildErrorMessage(
      BuildContext context, Animation<double> animation, ErrorMessage message) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedMessageBox(
      animation: animation,
      message: message.toLocalizedString(l10n),
      containerColor: theme.colorScheme.errorContainer,
      onContainerColor: theme.colorScheme.onErrorContainer,
      onTap: message == ErrorMessage.loginRequired
          ? () => Navigator.pushNamed(context, LoginFlowPage.routeName)
          : message == ErrorMessage.grantLocationPermission
              ? () => Geolocator.openAppSettings()
              : message == ErrorMessage.enableLocationServices
                  ? () => Geolocator.openLocationSettings()
                  : null,
    );
  }

  Widget _buildVerifyMessage(
      BuildContext context, Animation<double> animation, VerifyTime verifyTime) {
    return VerifyMessageBox(animation, verifyTime, () {
      if (verifyTime.dateTime != null) {
        Navigator.pushNamed(context, ImageVerificationPage.routeName);
      } else {
        assert(verifyTime.isAcceptingToReviewPending == true);
        openAcceptToReviewDialog(context).then((accepted) {
          if (accepted != null) {
            get<Backend>().setAcceptedToReview(accepted).then((_) {
              if (accepted) {
                Navigator.pushNamed(context, ImageVerificationPage.routeName);
              } else {
                get<VerifyTimeProvider>().onAcceptedToReviewSettingChanged(false);
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    appOpenedTimer.cancel();
  }
}
