import 'package:flutter/material.dart';

class SwitchWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool checked;
  final void Function(bool) onCheckedChanged;

  const SwitchWidget(
      {super.key,
      required this.title,
      this.description = "",
      required this.checked,
      required this.onCheckedChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                if (description.isNotEmpty) Text(description),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: checked, onChanged: onCheckedChanged),
        ],
      ),
    );
  }
}
