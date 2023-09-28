import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/pill.dart';
import 'package:insigno_frontend/page/pill_page.dart';

class PillWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  PillWidget({super.key});

  @override
  State<PillWidget> createState() => _PillWidgetState();
}

class _PillWidgetState extends State<PillWidget>
    with GetItStateMixin<PillWidget>, SingleTickerProviderStateMixin<PillWidget> {
  Pill? pill;
  late final AnimationController pillAnim;

  @override
  void initState() {
    super.initState();

    pillAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    get<Backend>().loadRandomPill().then((value) {
      setState(() {
        pill = value;
        pillAnim.forward();
      });
    }, onError: (_) {
      // ignore errors when loading pills
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return FadeTransition(
      opacity: pillAnim,
      child: Padding(
        padding: EdgeInsets.only(top: mediaQuery.padding.top + 8),
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: theme.colorScheme.secondaryContainer,
          elevation: 6, // just like FABs
          child: InkWell(
            onTap: () {
              if (pill != null) {
                pillAnim.reverse();
                Navigator.pushNamed(context, PillPage.routeName, arguments: pill!);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: BoxConstraints(
                maxWidth: mediaQuery.size.width -
                    112 -
                    mediaQuery.padding.right -
                    mediaQuery.padding.left,
              ),
              child: Text(
                pill?.text ?? "",
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    height: 1.3,
                    color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
