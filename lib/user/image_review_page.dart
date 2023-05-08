import 'package:collection/collection.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/marker_image.dart';
import 'package:insigno_frontend/networking/data/review_verdict.dart';
import 'package:insigno_frontend/util/error_text.dart';
import 'package:insigno_frontend/util/image.dart';
import 'package:insigno_frontend/util/nullable.dart';

class ImageReviewPage extends StatefulWidget {
  static const routeName = '/imageReviewPage';

  const ImageReviewPage({Key? key}) : super(key: key);

  @override
  State<ImageReviewPage> createState() => _ImageReviewPageState();
}

class _ImageReviewPageState extends State<ImageReviewPage> {
  bool loading = true;
  List<MarkerImage> images = [];
  String? errorLoading;
  String? errorReviewing;

  @override
  void initState() {
    super.initState();
    loadMoreImages();
  }

  void loadMoreImages() {
    getIt<Backend>().getToReview().then((value) {
      setState(() {
        loading = false;
        images.addAll(value);
      });
    }, onError: (e) {
      setState(() {
        loading = false;
        errorLoading = e.toString();
      });
    });
  }

  void sendVerdict(ReviewVerdict verdict) {
    setState(() {
      loading = true;
      errorReviewing = null;
    });
    getIt<Backend>().review(images.first.id, verdict).then((_) {
      if (images.length == 1) {
        images.removeAt(0);
        loadMoreImages();
      } else {
        setState(() {
          images.removeAt(0);
          loading = false;
        });
      }
    }, onError: (e) {
      setState(() {
        loading = false;
        errorReviewing = e.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final image = images.firstOrNull?.map((image) => imageFromNetwork(imageId: image.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewImages)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const CircularProgressIndicator()
              : errorLoading != null
                  ? ErrorText(errorLoading, l10n.errorLoading)
                  : images.isEmpty
                      ? Text(l10n.noImageToReview)
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(16)),
                                child: GestureDetector(
                                  onTap: () {
                                    showImageViewerPager(
                                      context,
                                      SingleImageProvider(image!.image),
                                      closeButtonTooltip: l10n.close,
                                      doubleTapZoomable: true,
                                    );
                                  },
                                  child: image,
                                ),
                              ),
                            ),
                            ErrorText(errorReviewing, l10n.errorReviewing, spaceAbove: 16),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      sendVerdict(ReviewVerdict.ok);
                                    },
                                    child: Text(
                                      l10n.verdictOk,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (images.length == 1) {
                                        setState(() {
                                          images.removeAt(0);
                                          loading = true;
                                          errorLoading = null;
                                        });
                                        loadMoreImages();
                                      } else {
                                        setState(() {
                                          images.removeAt(0);
                                        });
                                      }
                                    },
                                    child: Text(
                                      l10n.verdictSkip,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      sendVerdict(ReviewVerdict.delete);
                                    },
                                    child: Text(
                                      l10n.verdictDelete,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      sendVerdict(ReviewVerdict.deleteReport);
                                    },
                                    child: Text(
                                      l10n.verdictDeleteReport,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}
