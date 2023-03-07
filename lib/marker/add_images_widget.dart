import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insignio_frontend/util/iterable.dart';

import '../util/pair.dart';

class AddImagesWidget extends StatelessWidget {
  final List<Pair<Uint8List, String?>> images;
  final void Function(Pair<Uint8List, String?>)? addImageCallback;
  final void Function(int)? removeImageCallback;

  const AddImagesWidget(this.images, this.addImageCallback, this.removeImageCallback, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color bgColor = colors.primaryContainer;
    final Color fgColor = colors.onPrimaryContainer;
    // see ElevatedButton lines 195 and 200 (using same colors here)
    final Color bgDisabledColor = colors.onSurface.withOpacity(0.12);
    final Color fgDisabledColor = colors.onSurface.withOpacity(0.38);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[const SizedBox(width: 16)]
            .followedBy(images.expandIndexed<Widget>((index, image) => [
                  Stack(alignment: Alignment.topRight, children: [
                    ClipRRect(
                      child: Image.memory(
                        image.first,
                        height: 128,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Material(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: Ink(
                          color: removeImageCallback == null ? bgDisabledColor : bgColor,
                          child: InkWell(
                            onTap: removeImageCallback == null
                                ? null
                                : () => removeImageCallback!(index),
                            child: SizedBox(
                              child: Icon(
                                Icons.close,
                                size: 24,
                                color: removeImageCallback == null ? fgDisabledColor : fgColor,
                              ),
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(width: 16),
                ]))
            .followedBy([
          Ink(
            decoration: BoxDecoration(
              color: addImageCallback == null ? bgDisabledColor : bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: InkWell(
              onTap: captureImage,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: SizedBox(
                child: Icon(
                  Icons.add,
                  size: 48,
                  color: addImageCallback == null ? fgDisabledColor : fgColor,
                ),
                width: 96,
                height: 128,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ]).toList(growable: false),
      ),
    );
  }

  void captureImage() async {
    await ImagePicker().pickImage(source: ImageSource.camera).then((value) async {
      if (value != null && addImageCallback != null) {
        addImageCallback!(Pair(await File(value.path).readAsBytes(), value.mimeType));
      }
    });
  }
}
