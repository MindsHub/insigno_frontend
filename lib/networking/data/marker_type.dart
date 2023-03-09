import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum MarkerType {
  unknown(1, Colors.grey, Icons.help),
  plastic(2, Colors.indigo, Icons.polymer),
  paper(3, Colors.yellow, Icons.auto_stories),
  undifferentiated(4, Colors.red, Icons.broken_image),
  glass(5, Colors.green, Icons.liquor),
  compost(6, Colors.brown, Icons.compost),
  electronics(7, Colors.purple, Icons.local_laundry_service);

  final int id;
  final Color color;
  final IconData icon;

  const MarkerType(this.id, this.color, this.icon);

  Icon getThemedIcon(final BuildContext context) {
    return Icon(icon,
        color: HSLColor.fromColor(color)
            .withLightness(Theme.of(context).brightness == Brightness.dark ? 0.7 : 0.3)
            .toColor());
  }

  String getName(final BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MarkerType.unknown:
        return l10n.markerTypeUnknown;
      case MarkerType.plastic:
        return l10n.markerTypePlastic;
      case MarkerType.paper:
        return l10n.markerTypePaper;
      case MarkerType.undifferentiated:
        return l10n.markerTypeUndifferentiated;
      case MarkerType.glass:
        return l10n.markerTypeGlass;
      case MarkerType.compost:
        return l10n.markerTypeCompost;
      case MarkerType.electronics:
        return l10n.markerTypeElectronics;
    }
  }
}
