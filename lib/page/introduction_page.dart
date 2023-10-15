import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:insigno_frontend/util/image.dart';

class IntroductionPage extends StatefulWidget {
  static const routeName = '/introductionPage';

  final void Function(BuildContext) onDone;

  const IntroductionPage({Key? key, required this.onDone}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  List<String>? _imageUrls;
  int _i = 0;
  final _pageController = PageController();
  NetworkImage? _image;

  @override
  void initState() {
    super.initState();

    getIt<Backend>().getIntroImages().then((value) {
      if (value.isEmpty) {
        widget.onDone(context);
      } else {
        setState(() {
          _imageUrls = value;
        });
      }
    }, onError: (e) {
      widget.onDone(context);
    });
  }

  void setPosition(int position) {
    setState(() {
      _i = position;
    });
    _pageController.jumpToPage(_i);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // use this *local* variable to avoid using ! to null check
    final imageUrls = _imageUrls;

    return Scaffold(
      backgroundColor: const Color(0xFFC9F687),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: imageUrls == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (i) => setState(() => _i = i),
                      itemBuilder: (context, i) {
                        // remove the previous image from cache to avoid strange gif glitches
                        _image?.evict();
                        _image = NetworkImage(imageUrls[i]);
                        return Image(
                          image: _image!,
                          loadingBuilder: imageLoadingBuilder,
                        );
                      },
                    ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ElevatedButton(
                    onPressed: () => widget.onDone(context),
                    child: Text(l10n.introSkip),
                  ),
                ),
                if (imageUrls != null)
                  DotsIndicator(
                    dotsCount: imageUrls.length,
                    position: _i,
                    decorator: const DotsDecorator(
                      spacing: EdgeInsets.symmetric(horizontal: 2),
                      activeSize: Size(12, 5),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                    onTap: setPosition,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (imageUrls == null) {
                          return;
                        } else if (_i < imageUrls.length - 1) {
                          setPosition(_i + 1);
                        } else {
                          widget.onDone(context);
                        }
                      });
                    },
                    child: Icon(imageUrls == null || _i < imageUrls.length - 1
                        ? Icons.forward
                        : Icons.start),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
