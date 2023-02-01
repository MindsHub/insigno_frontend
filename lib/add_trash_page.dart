import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'camera/camera.dart';
import 'networking/const.dart';
/*
class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget>*/

class AddTrashScreen extends StatefulWidget {
  const AddTrashScreen({Key? key}) : super(key: key);

  @override
  State<AddTrashScreen> createState() => AddTrashScreenState();
}

class AddTrashScreenState extends State<AddTrashScreen> {
  File? image;
  String? imagePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('First Route'),
        ),
        body: Column(children: [
          Row(children: [
            image != null
                ? kIsWeb
                    ? Image.network(
                        image!.path,
                        height: 60.0,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        image!,
                        height: 60.0,
                        fit: BoxFit.cover,
                      )
                : const Icon(Icons.image, size: 60),
            ElevatedButton(
              child: const Text('Carica da file'),
              onPressed: () {
                getPictureFromSource().then((value) {
                  setState(() {
                    image = File(value!.path);
                    imagePath = value!.path;
                  });
                });
              },
            ),
            !kIsWeb
                ? ElevatedButton(
                    child: const Text('Scatta con la camera'),
                    onPressed: () {
                      getPictureFromCamera().then((value) {
                        setState(() {
                          image = File(value!.path);
                          imagePath = value!.path;
                        });
                      });
                    },
                  )
                : Container(),
          ]),
          Row(children: [
            ElevatedButton(
              child: const Text('Invia'),
              onPressed: () async {
                final snackBar = SnackBar(
                  content: const Text('Non è stato possibile segnalare!'),
                  action: SnackBarAction(
                    label: 'Nuu',
                    onPressed: () {},
                  ),
                );

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                if (!await addTrash(image, imagePath)) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ElevatedButton(
              child: const Text('Esci'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ]),
        ]));
  }
}
