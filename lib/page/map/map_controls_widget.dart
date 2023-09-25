import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/page/map/location_provider.dart';
import 'package:insigno_frontend/page/map/map_page.dart';

class MapControlsWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  final MapController mapController;

  MapControlsWidget(this.mapController, {super.key});

  @override
  State<MapControlsWidget> createState() => _MapControlsWidgetState();
}

class _MapControlsWidgetState extends State<MapControlsWidget>
    with GetItStateMixin<MapControlsWidget>, SingleTickerProviderStateMixin<MapControlsWidget> {
  static const Duration repositionAnimDuration = Duration(milliseconds: 200);
  late final AnimationController repositionAnim;

  @override
  void initState() {
    super.initState();
    repositionAnim = AnimationController(vsync: this, duration: repositionAnimDuration);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;

    if (position?.position == null) {
      repositionAnim.reverse();
    } else {
      repositionAnim.forward();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        right: MediaQuery.of(context).padding.right,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: FloatingActionButton(
              heroTag: "north",
              onPressed: () => widget.mapController.rotate(0),
              tooltip: l10n.alignNorth,
              mini: true,
              child: const Icon(Icons.explore),
            ),
          ),
          AnimatedBuilder(
            animation: repositionAnim,
            builder: (_, child) => ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: repositionAnim.value,
                widthFactor: repositionAnim.value,
                child: child,
              ),
            ),
            child: ScaleTransition(
              scale: repositionAnim,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 16),
                child: FloatingActionButton(
                  heroTag: "reposition",
                  onPressed: () =>
                      widget.mapController.move(position!.toLatLng()!, defaultInitialZoom),
                  tooltip: l10n.goToPosition,
                  mini: true,
                  child: const Icon(Icons.filter_tilt_shift),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
