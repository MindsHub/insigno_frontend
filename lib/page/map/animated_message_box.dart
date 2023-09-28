import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedMessageBox extends AnimatedWidget {
  final String message;
  final Color containerColor;
  final Color onContainerColor;
  final VoidCallback? onTap;

  const AnimatedMessageBox(
      {super.key,
      required Animation<double> animation,
      required this.message,
      required this.containerColor,
      required this.onContainerColor,
      this.onTap})
      : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Material(
            color: containerColor,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            elevation: 6,
            // manually using ClipRect+Align instead of SizeTransition to set the widthFactor to 1.0
            // and therefore make the child be wrapped
            child: InkWell(
              onTap: onTap,
              child: ClipRect(
                child: Align(
                  widthFactor: 1.0,
                  heightFactor: max(animation.value, 0.0),
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      message,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.3,
                        color: onContainerColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
