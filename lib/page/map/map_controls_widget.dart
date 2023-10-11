import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/provider/location_provider.dart';
import 'package:insigno_frontend/page/map/map_page.dart';
import 'package:insigno_frontend/page/scoreboard/scoreboard_page.dart';

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
    final mediaQuery = MediaQuery.of(context);
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            get<LocationProvider>().lastLocationInfo())
        .data;

    if (position?.position == null) {
      repositionAnim.reverse();
    } else {
      repositionAnim.forward();
    }

    return Padding(
      // the right padding is handled by children to allow the AnimatedBuilder shadow to expand
      padding: EdgeInsets.only(top: mediaQuery.padding.top),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 8,
              top: 8,
              right: 8 + mediaQuery.padding.right,
            ),
            child: FloatingActionButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              heroTag: "scoreboard",
              onPressed: () => Navigator.pushNamed(
                context,
                ScoreboardPage.routeName,
                arguments: position?.toLatLng() ?? widget.mapController.center,
              ),
              tooltip: l10n.scoreboard,
              mini: true,
              child: const Icon(Icons.emoji_events),
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
                padding: EdgeInsets.only(
                  left: 8,
                  top: 8,
                  right: 8 + mediaQuery.padding.right,
                  bottom: 16,
                ),
                child: FloatingActionButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  heroTag: "reposition",
                  onPressed: () {
                    widget.mapController.move(position!.toLatLng()!, defaultInitialZoom);
                  },
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
