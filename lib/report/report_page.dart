import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import "package:os_detect/os_detect.dart" as platform;

import '../auth/authentication.dart';
import '../di/setup.dart';
import '../map/location.dart';
import 'camera.dart';

class ReportPage extends StatefulWidget with GetItStatefulWidgetMixin {
  ReportPage({super.key});

  static const routeName = "/reportPage";

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with GetItStateMixin<ReportPage> {
  Uint8List? image;

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
              if (image == null)
                const Icon(Icons.image, size: 128)
              else
                ClipRRect(
                  child: Image.memory(
                    image!,
                    height: 128,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: const Text('Carica da file'),
                    onPressed: () {
                      FilePicker.platform.pickFiles(withData: true).then((value) {
                        var bytes = value?.files.single.bytes;
                        if (bytes != null) {
                          setState(() => image = bytes);
                        }
                      });
                    },
                  ),
                  if (platform.isAndroid || platform.isIOS) const SizedBox(width: 16),
                  if (platform.isAndroid || platform.isIOS)
                    ElevatedButton(
                        child: const Text("Scatta"),
                        onPressed: () {
                          getPictureFromCamera().then((value) async {
                                if (value != null) {
                                  return await File(value.path).readAsBytes();
                                } else {
                                  return null;
                                }
                              }).then((value) {
                                if (value != null) {
                                  setState(() => image = value);
                                }
                              });
                        })
                ],
              ),
              if (!isLoggedIn)
                const Text("You must log in in order to report")
              else if (position?.permissionGranted == false)
                const Text("Grant permission to access location in order to report")
              else if (position?.servicesEnabled == false)
                const Text("Enable location services in order to report")
              else if (position?.position == null)
                const Text("Location is loading, please wait...")
              else
                ElevatedButton(onPressed: () {}, child: const Text("Invia"))
            ],
          ),
        )));
  }
}
