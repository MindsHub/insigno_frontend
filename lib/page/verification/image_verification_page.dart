import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/networking/data/image_verification.dart';
import 'package:insigno_frontend/page/marker/image_list_widget.dart';
import 'package:insigno_frontend/provider/auth_user_provider.dart';
import 'package:insigno_frontend/provider/verify_time_provider.dart';
import 'package:insigno_frontend/util/error_text.dart';
import 'package:insigno_frontend/util/image.dart';

class ImageVerificationPage extends StatefulWidget with GetItStatefulWidgetMixin {
  static const routeName = '/imageVerificationPage';

  ImageVerificationPage({super.key});

  @override
  State<ImageVerificationPage> createState() => _ImageVerificationPageState();
}

class _ImageVerificationPageState extends State<ImageVerificationPage>
    with GetItStateMixin<ImageVerificationPage> {
  List<ImageVerification>? verifications;
  String? loadError;
  int i = 0;
  String? errorReviewing;

  @override
  void initState() {
    super.initState();

    get<Backend>() //
        .getVerifySession()
        .then((value) {
      setState(() {
        verifications = value;
        i = value.indexWhere((verification) => verification.verdict == null);
      });
    }, onError: (e) {
      loadError = e.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final theVerifications = verifications;
    final theLoadError = loadError;
    if (theVerifications == null || i < 0 || i >= theVerifications.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.verifyImages),
        ),
        body: Center(
          child: theVerifications != null //
              ? Text(l10n.mindshubDescription)
              : theLoadError == null
                  ? const CircularProgressIndicator()
                  : Text(
                      theLoadError,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
        ),
      );
    }
    var verification = theVerifications[i];

    final mainImage = imageFromNetwork(
      imageId: verification.imageId,
      fit: BoxFit.contain,
    );

    final otherImages = verification.markerImages.where((e) => e != verification.imageId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyImages),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.partialOutOfTotal(i + 1, theVerifications.length),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(width: 6),
                Icon(
                  verification.markerType.icon,
                  size: 48,
                  color: verification.markerType.color,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showImageViewerPager(
                    context,
                    SingleImageProvider(mainImage.image),
                    closeButtonTooltip: l10n.close,
                    doubleTapZoomable: true,
                  );
                },
                child: mainImage,
              ),
            ),
            if (otherImages.isNotEmpty) const SizedBox(height: 8),
            if (otherImages.isNotEmpty)
              ImageListWidget(
                  otherImages.map((image) => imageFromNetwork(imageId: image, height: 64))),
            ErrorText(
              errorReviewing,
              l10n.errorReviewing,
              topPadding: 16,
              horizontalPadding: 16,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => sendVerdict(verification.imageId, false),
                    child: Text(
                      l10n.verdictBad,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => sendVerdict(verification.imageId, true),
                    child: Text(
                      l10n.verdictOk,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void sendVerdict(int imageId, bool verdict) {
    if (errorReviewing != null) {
      setState(() {
        errorReviewing = null;
      });
    }

    get<Backend>().setVerifyVerdict(imageId, verdict).then((awardedPoints) {
      if (awardedPoints == null) {
        setState(() {
          i += 1;
        });
      } else {
        get<AuthUserProvider>().addPoints(awardedPoints);
        get<VerifyTimeProvider>().update();
        Navigator.pop(context);
      }
    });
  }
}
