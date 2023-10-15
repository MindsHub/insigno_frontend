import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/provider/auth_user_provider.dart';

// see additional_points_curve.ggb Geogebra file
class _PositionCurve extends Curve {
  final double enterExponent;
  final double exitExponent;
  final double enterTime;
  final double exitTime;
  final double cutoff;

  const _PositionCurve(
      this.enterExponent, this.exitExponent, this.enterTime, this.exitTime, this.cutoff);

  @override
  double transformInternal(double t) {
    if (t < enterTime) {
      return cutoff * (1.0 - exp(-enterExponent * t)) / (1.0 - exp(-enterExponent * enterTime));
    } else if (t < exitTime) {
      return cutoff;
    } else {
      return cutoff +
          (exp(exitExponent * (t - exitTime) / (1.0 - exitTime)) - 1.0) /
              exp(exitExponent) *
              (1.0 - cutoff);
    }
  }
}

class _FadeCurve extends Curve {
  final double enterExponent;
  final double exitExponent;
  final double enterTime;
  final double exitTime;

  const _FadeCurve(this.enterExponent, this.exitExponent, this.enterTime, this.exitTime);

  @override
  double transformInternal(double t) {
    if (t < enterTime) {
      return 1.0 - pow(((t - enterTime) / enterTime).abs(), enterExponent);
    } else if (t < exitTime) {
      return 1.0;
    } else {
      return 1.0 - pow(((t - exitTime) / (1.0 - exitTime)).abs(), enterExponent);
    }
  }
}

class AdditionalPointsWidget extends StatefulWidget {
  const AdditionalPointsWidget({super.key});

  @override
  State<AdditionalPointsWidget> createState() => _AdditionalPointsWidgetState();
}

class _AdditionalPointsWidgetState extends State<AdditionalPointsWidget>
    with SingleTickerProviderStateMixin<AdditionalPointsWidget> {
  late final AnimationController _controller;
  late final Animation<Offset> _positionAnimation;
  late final Animation<double> _fadeAnimation;
  double _lastAdditionalPoints = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _positionAnimation = Tween<Offset>(
      begin: const Offset(0.0, -8.0),
      end: const Offset(0.0, 8.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const _PositionCurve(30.0, 10.0, 0.2, 0.8, 8.0 / 16.0),
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const _FadeCurve(3.0, 2.0, 0.1, 0.9),
    );

    getIt<AuthUserProvider>() //
        .getAdditionalPointsStream()
        .forEach((additionalPoints) {
      _controller.forward(from: 0.0);
      setState(() {
        _lastAdditionalPoints = additionalPoints;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16 + mediaQuery.padding.left,
        right: 16 + mediaQuery.padding.right,
        bottom: 16 + 72 + mediaQuery.padding.bottom,
      ),
      child: SlideTransition(
        position: _positionAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l10n.additional_points(_lastAdditionalPoints),
                style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
