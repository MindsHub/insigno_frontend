import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gif/gif.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatefulWidget {
  static const routeName = '/introductionPage';

  final void Function(BuildContext) onDone;

  const IntroductionPage({Key? key, required this.onDone}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  List<String>? imageUrls;

  @override
  void initState() {
    super.initState();

    getIt<Backend>().getIntroImages().then((value) {
      if (value.isEmpty) {
        widget.onDone(context);
      } else {
        setState(() {
          imageUrls = value;
        });
      }
    }, onError: (e) {
      widget.onDone(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFC9F687),
      body: IntroductionScreen(
        controlsPadding: EdgeInsets.zero,
        rawPages: [
          if (imageUrls == null)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            for (var imageUrl in imageUrls!)
              Center(
                child: Gif(
                  image: NetworkImage(imageUrl),
                  placeholder: (_) => const CircularProgressIndicator(),
                  autostart: Autostart.once,
                ),
              ),
        ],
        onSkip: () => widget.onDone(context),
        onDone: () => widget.onDone(context),
        //ClampingScrollPhysics prevent the scroll offset from exceeding the bounds of the content.
        scrollPhysics: const ClampingScrollPhysics(),
        showDoneButton: true,
        showNextButton: true,
        showSkipButton: true,
        skip: Text(l10n.introSkip),
        next: const Icon(Icons.forward),
        done: Text(l10n.introStart),
        dotsDecorator: const DotsDecorator(
          spacing: EdgeInsets.symmetric(horizontal: 2),
          activeSize: Size(12, 5),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }

  PageDecoration getPageDecoration() {
    return const PageDecoration(
        imagePadding: EdgeInsets.zero,
        contentMargin: EdgeInsets.zero,
        pageMargin: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        bodyPadding: EdgeInsets.zero,
        pageColor: Colors.white,
        bodyFlex: 0,
        footerFlex: 0,
        titleTextStyle: TextStyle(
          fontSize: 0,
        ),
        bodyTextStyle: TextStyle(
          fontSize: 0,
        ));
  }
}
