import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/page/map/animated_message_box.dart';
import 'package:insigno_frontend/page/verification/image_verification_page.dart';
import 'package:insigno_frontend/util/time.dart';

class VerifyMessageBox extends StatefulWidget {
  final Animation<double> animation;
  final DateTime time;

  const VerifyMessageBox(this.animation, this.time, {super.key});

  @override
  State<VerifyMessageBox> createState() => _VerifyMessageBoxState();
}

class _VerifyMessageBoxState extends State<VerifyMessageBox> {
  Timer? _timer;
  DateTime? _lastTimerTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // .subtract(Duration(days: 190, hours: 18))
    final inThePast = widget.time.isBefore(DateTime.now());
    
    if (inThePast) {
      if (_timer != null) {
        _timer?.cancel();
        _timer = null;
      }
    } else {
      if (_timer == null || _timer?.isActive != true || _lastTimerTime != widget.time) {
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
      }
    }

    return AnimatedMessageBox(
      animation: widget.animation,
      message: inThePast
          ? l10n.verifyImages
          : l10n.verifyImagesIn(formatDuration(widget.time.difference(DateTime.now()))),
      containerColor: theme.colorScheme.tertiaryContainer,
      onContainerColor: theme.colorScheme.onTertiaryContainer,
      onTap: inThePast //
          ? () => Navigator.pushNamed(context, ImageVerificationPage.routeName)
          : null,
    );
  }
}
