import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../auth/authentication.dart';
import '../di/setup.dart';
import '../map/location.dart';

class ReportPage extends StatefulWidget with GetItStatefulWidgetMixin {
  ReportPage({super.key});

  static const routeName = "/reportPage";

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with GetItStateMixin<ReportPage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final position = watchStream((LocationProvider location) => location.getLocationStream(),
            getIt<LocationProvider>().lastLocationInfo())
        .data;
    final bool isLoggedIn = watchStream(
                (Authentication authentication) => authentication.getIsLoggedInStream(),
                getIt<Authentication>().isLoggedIn())
            .data ??
        false;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Report"),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isLoggedIn)
                const Text("You must log in in order to report")
              else if (position?.permissionGranted == false)
                const Text("Grant permission to access location in order to report")
              else if (position?.servicesEnabled == false)
                const Text("Enable location services in order to report")
              else if (position?.position == null)
                const Text("Location is loading, please wait..."),
            ],
          ),
        )));
  }
}
