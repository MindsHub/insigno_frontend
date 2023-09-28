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
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: MarkerType.values.map<Widget>((markerType) {
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.only(right: 8),
                    label: Text(markerType.getName(context)),
                    avatar: markerType.getThemedIcon(context),
                    selected: shownMarkers.contains(markerType),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          shownMarkers.add(markerType);
                        } else {
                          shownMarkers.remove(markerType);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(
              height: 4,
              thickness: 1,
            ),
            CheckboxListTile(
              title: Text(l10n.includeResolved),
              value: includeResolved,
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                if (value != null) {
                  setState(() => includeResolved = value);
                }
              },
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
