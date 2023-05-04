import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class SettingsPage extends StatefulWidget with GetItStatefulWidgetMixin {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with GetItStateMixin<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.of(context).padding.top, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (kDebugMode)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text("Crash sync"),
                    onPressed: () => throw Exception("Synccc"),
                  ),
                  TextButton(
                    child: const Text("Crash async"),
                    onPressed: () => Future.delayed(
                        const Duration(seconds: 0), () => throw Exception("Asynccc")),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
