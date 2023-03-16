import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String? errorString;
  final String Function(String errorString) formatter;
  final double spaceAbove;
  final double spaceBelow;
  final TextAlign textAlign;

  const ErrorText(this.errorString, this.formatter,
      {this.spaceAbove = 0, this.spaceBelow = 0, this.textAlign = TextAlign.center, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorString == null) {
      return const SizedBox();
    }
    final theme = Theme.of(context);

    final text = Text(
      formatter(errorString!),
      style: TextStyle(color: theme.colorScheme.error),
      textAlign: textAlign,
    );

    if (spaceAbove <= 0 && spaceBelow <= 0) {
      return text;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (spaceAbove > 0) SizedBox(height: spaceAbove),
        text,
        if (spaceBelow > 0) SizedBox(height: spaceBelow),
      ],
    );
  }
}
