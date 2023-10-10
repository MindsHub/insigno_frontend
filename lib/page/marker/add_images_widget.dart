import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insigno_frontend/util/nullable.dart';
import 'package:insigno_frontend/util/pair.dart';
import 'package:os_detect/os_detect.dart' as Platform;

class AddImagesWidget extends StatelessWidget {
  static const imageHeight = 256.0;

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
    final Color bgDisabledColor =
        Color.alphaBlend(colors.onSurface.withOpacity(0.12), colors.surface);
    final Color fgDisabledColor =
        Color.alphaBlend(colors.onSurface.withOpacity(0.38), colors.surface);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[const SizedBox(width: 16)]
            .followedBy(images.expandIndexed<Widget>((index, image) => [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: Image.memory(
                          image.first,
                          height: imageHeight,
                          fit: BoxFit.cover,
                        ),
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
                              onTap: removeImageCallback?.map((f) => () => f(index)),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: removeImageCallback == null ? fgDisabledColor : fgColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ]))
            .followedBy([
          Ink(
            decoration: BoxDecoration(
              color: addImageCallback == null ? bgDisabledColor : bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: InkWell(
              onTap: addImageCallback?.map((_) => captureImage),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: SizedBox(
                width: imageHeight / 1.618,
                height: imageHeight,
                child: Icon(
                  Icons.add_a_photo,
                  size: 64,
                  color: addImageCallback == null ? fgDisabledColor : fgColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ]).toList(growable: false),
      ),
    );
  }

  void captureImage() async {
    if (Platform.isLinux) {
      addImageCallback!(Pair(
        Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72] +
            [68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144] +
            [119, 83, 222, 0, 0, 1, 132, 105, 67, 67, 80, 73, 67, 67, 32, 112] +
            [114, 111, 102, 105, 108, 101, 0, 0, 40, 145, 125, 145, 61, 72, 195, 64] +
            [28, 197, 95, 91, 165, 34, 245, 3, 90, 65, 196, 33, 67, 117, 178, 32] +
            [42, 226, 168, 85, 40, 66, 133, 80, 43, 180, 234, 96, 114, 233, 23, 52] +
            [105, 72, 82, 92, 28, 5, 215, 130, 131, 31, 139, 85, 7, 23, 103, 93] +
            [29, 92, 5, 65, 240, 3, 196, 213, 197, 73, 209, 69, 74, 252, 95, 82] +
            [104, 17, 227, 193, 113, 63, 222, 221, 123, 220, 189, 3, 252, 245, 50, 83] +
            [205, 142, 113, 64, 213, 44, 35, 149, 136, 11, 153, 236, 170, 16, 124, 69] +
            [0, 97, 244, 162, 31, 3, 18, 51, 245, 57, 81, 76, 194, 115, 124, 221] +
            [195, 199, 215, 187, 24, 207, 242, 62, 247, 231, 232, 81, 114, 38, 3, 124] +
            [2, 241, 44, 211, 13, 139, 120, 131, 120, 122, 211, 210, 57, 239, 19, 71] +
            [88, 81, 82, 136, 207, 137, 199, 12, 186, 32, 241, 35, 215, 101, 151, 223] +
            [56, 23, 28, 246, 243, 204, 136, 145, 78, 205, 19, 71, 136, 133, 66, 27] +
            [203, 109, 204, 138, 134, 74, 60, 69, 28, 85, 84, 141, 242, 253, 25, 151] +
            [21, 206, 91, 156, 213, 114, 149, 53, 239, 201, 95, 24, 202, 105, 43, 203] +
            [92, 167, 57, 140, 4, 22, 177, 4, 17, 2, 100, 84, 81, 66, 25, 22] +
            [98, 180, 106, 164, 152, 72, 209, 126, 220, 195, 63, 228, 248, 69, 114, 201] +
            [228, 42, 129, 145, 99, 1, 21, 168, 144, 28, 63, 248, 31, 252, 238, 214] +
            [204, 79, 78, 184, 73, 161, 56, 208, 249, 98, 219, 31, 35, 64, 112, 23] +
            [104, 212, 108, 251, 251, 216, 182, 27, 39, 64, 224, 25, 184, 210, 90, 254] +
            [74, 29, 152, 249, 36, 189, 214, 210, 162, 71, 64, 223, 54, 112, 113, 221] +
            [210, 228, 61, 224, 114, 7, 24, 124, 210, 37, 67, 114, 164, 0, 77, 127] +
            [62, 15, 188, 159, 209, 55, 101, 129, 240, 45, 208, 189, 230, 246, 214, 220] +
            [199, 233, 3, 144, 166, 174, 146, 55, 192, 193, 33, 48, 90, 160, 236, 117] +
            [143, 119, 119, 181, 247, 246, 239, 153, 102, 127, 63, 40, 59, 114, 137, 225] +
            [68, 226, 186, 0, 0, 0, 9, 112, 72, 89, 115, 0, 0, 46, 35, 0] +
            [0, 46, 35, 1, 120, 165, 63, 118, 0, 0, 0, 7, 116, 73, 77, 69] +
            [7, 231, 3, 19, 14, 17, 7, 5, 186, 152, 130, 0, 0, 0, 25, 116] +
            [69, 88, 116, 67, 111, 109, 109, 101, 110, 116, 0, 67, 114, 101, 97, 116] +
            [101, 100, 32, 119, 105, 116, 104, 32, 71, 73, 77, 80, 87, 129, 14, 23] +
            [0, 0, 0, 12, 73, 68, 65, 84, 8, 215, 99, 248, 207, 192, 0, 0] +
            [3, 1, 1, 0, 24, 221, 141, 176, 0, 0, 0, 0, 73, 69, 78, 68] +
            [174, 66, 96, 130]),
        "image/png",
      ));
      return;
    }

    await ImagePicker().pickImage(source: ImageSource.camera).then((value) async {
      if (value != null && addImageCallback != null) {
        addImageCallback!(Pair(await File(value.path).readAsBytes(), value.mimeType));
      }
    });
  }
}
