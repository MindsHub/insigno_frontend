import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/networking/data/image_verification.dart';
import 'package:insigno_frontend/page/map/animated_message_box.dart';
import 'package:insigno_frontend/util/time.dart';

class VerifyMessageBox extends StatefulWidget {
  final Animation<double> animation;
  final VerifyTime verifyTime;
  final void Function() onTap;

  const VerifyMessageBox(this.animation, this.verifyTime, this.onTap, {super.key});

  @override
  State<VerifyMessageBox> createState() => _VerifyMessageBoxState();
}

class _VerifyMessageBoxState extends State<VerifyMessageBox> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // .subtract(Duration(days: 190, hours: 18))
    final canVerifyNow = widget.verifyTime.canVerifyNow();

    if (canVerifyNow) {
      if (_timer != null) {
        _timer?.cancel();
        _timer = null;
      }
    } else {
      if (_timer == null || _timer?.isActive != true) {
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
      }
    }

    return AnimatedMessageBox(
      animation: widget.animation,
      message: canVerifyNow
          ? l10n.verifyImages
          : l10n.verifyImagesIn(
              formatDuration(widget.verifyTime.dateTime!.difference(DateTime.now()))),
      containerColor: theme.colorScheme.tertiaryContainer,
      onContainerColor: theme.colorScheme.onTertiaryContainer,
      onTap: canVerifyNow ? widget.onTap : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}
