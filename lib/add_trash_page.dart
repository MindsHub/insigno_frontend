import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:os_detect/os_detect.dart" as Platform;
import 'camera/camera.dart';

class AddTrashScreen extends StatefulWidget {
  const AddTrashScreen({Key? key}) : super(key: key);

  @override
  State<AddTrashScreen> createState() => AddTrashScreenState();
}

class AddTrashScreenState extends State<AddTrashScreen> {
  Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('First Route'),
        ),
        body: Column(children: [
          Row(children: [
            if (image == null)
              const Icon(Icons.image, size: 60)
            else
              Image.memory(
                image!,
                height: 60.0,
                fit: BoxFit.cover,
              ),
            ElevatedButton(
              child: const Text('Carica da file'),
              onPressed: () {
                FilePicker.platform.pickFiles(withData: true)
                    .then((value) {
                      var bytes = value?.files.single.bytes;
                      if (bytes != null) {
                        setState(() => image = bytes);
                      }
                    });
              },
            ),
            if (Platform.isAndroid || Platform.isIOS)
              ElevatedButton(
                  child: const Text('Scatta con la camera'),
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
          ]),
          Row(children: [
            if (image != null)
              ElevatedButton(
                child: const Text('Invia'),
                onPressed: () async {
                  if (!await addTrash(image!)) {
                    final snackBar = SnackBar(
                      content: const Text('Non è stato possibile segnalare!'),
                      action: SnackBarAction(
                        label: 'Nuu',
                        onPressed: () {},
                      ),
                    );
                    // Find the ScaffoldMessenger in the widget tree
                    // and use it to show a SnackBar.
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
