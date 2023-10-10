import 'package:collection/collection.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImageListWidget extends StatelessWidget {
  final Iterable<Image> imageProviders;

  const ImageListWidget(this.imageProviders, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: imageProviders
            .expandIndexed(
              (index, image) =>
          [
            if (index == 0) const SizedBox(width: 16),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: GestureDetector(
                onTap: () {
                  var imageProvider = MultiImageProvider(
                    imageProviders.map((e) => e.image).toList(growable: false),
                    initialIndex: index,
                  );
                  showImageViewerPager(
                    context,
                    imageProvider,
                    closeButtonTooltip: l10n.close,
                    doubleTapZoomable: true,
                  );
                },
                child: image,
              ),
            ),
            const SizedBox(width: 16),
          ],
        )
            .toList(growable: false),
      ),
    );
  }
}
