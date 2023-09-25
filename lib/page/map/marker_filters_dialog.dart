import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/networking/data/marker_type.dart';

class MarkerFilters {
  final Set<MarkerType> shownMarkers;
  final bool includeResolved;

  MarkerFilters(this.shownMarkers, this.includeResolved);
}

class MarkerFiltersDialog extends StatefulWidget {
  final MarkerFilters initialFilters;

  const MarkerFiltersDialog(this.initialFilters, {Key? key}) : super(key: key);

  @override
  State<MarkerFiltersDialog> createState() => _MarkerFiltersDialogState();
}

class _MarkerFiltersDialogState extends State<MarkerFiltersDialog> {
  late final Set<MarkerType> shownMarkers;
  late bool includeResolved;

  @override
  void initState() {
    super.initState();
    shownMarkers = Set.from(widget.initialFilters.shownMarkers);
    includeResolved = widget.initialFilters.includeResolved;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView(
              shrinkWrap: true,
              children: MarkerType.values
                  .map<Widget>((markerType) => CheckboxListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            markerType.getThemedIcon(context),
                            const SizedBox(width: 8),
                            Text(markerType.getName(context)),
                          ],
                        ),
                        value: shownMarkers.contains(markerType),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              if (value) {
                                shownMarkers.add(markerType);
                              } else {
                                shownMarkers.remove(markerType);
                              }
                            });
                          }
                        },
                      ))
                  .followedBy([
                const Divider(
                  height: 4,
                  thickness: 1,
                ),
                CheckboxListTile(
                  title: Text(l10n.includeResolved),
                  value: includeResolved,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => includeResolved = value);
                    }
                  },
                ),
              ]).toList(growable: false),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowSpacing: 4,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(
                        context,
                        MarkerFilters(
                          Set.unmodifiable(shownMarkers),
                          includeResolved,
                        )),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
