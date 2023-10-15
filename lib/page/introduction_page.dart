import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gif/gif.dart';
import 'package:insigno_frontend/di/setup.dart';
import 'package:insigno_frontend/networking/backend.dart';

class IntroductionPage extends StatefulWidget {
  static const routeName = '/introductionPage';

  final void Function(BuildContext) onDone;

  const IntroductionPage({Key? key, required this.onDone}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  List<String>? imageUrls;
  int i = 0;

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
    final urls = imageUrls;

    return Scaffold(
      backgroundColor: const Color(0xFFC9F687),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: urls == null
                    ? const CircularProgressIndicator()
                    : Gif(
                        image: NetworkImage(urls[i]),
                        placeholder: (_) => const CircularProgressIndicator(),
                        autostart: Autostart.once,
                      ),
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
                if (urls != null)
                  DotsIndicator(
                    dotsCount: urls.length,
                    position: i,
                    decorator: const DotsDecorator(
                      spacing: EdgeInsets.symmetric(horizontal: 2),
                      activeSize: Size(12, 5),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                    onTap: (position) => setState(() {
                      i = position;
                    }),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (urls == null) {
                          return;
                        } else if (i < urls.length - 1) {
                          setState(() {
                            i = i + 1;
                          });
                        } else {
                          widget.onDone(context);
                        }
                      });
                    },
                    child: urls == null || i < urls.length - 1
                        ? const Icon(Icons.forward)
                        : Text(l10n.introStart),
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
