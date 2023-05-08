import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String? errorString;
  final String Function(String errorString) formatter;
  final double topPadding;
  final double horizontalPadding;
  final TextAlign textAlign;

  const ErrorText(this.errorString, this.formatter,
      {this.topPadding = 0,
      this.horizontalPadding = 0,
      this.textAlign = TextAlign.center,
      Key? key})
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

    if (topPadding <= 0 && horizontalPadding <= 0) {
      return text;
    }

    return Padding(
      padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: topPadding),
      child: text,
    );
  }
}
