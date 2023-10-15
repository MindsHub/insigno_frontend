import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatelessWidget {
  static const routeName = '/introductionPage';

  final void Function(BuildContext) onDone;

  const IntroductionPage({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "",
            body: "",
            image: buildImage("assets/intro_screen/1.gif"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: "",
            body: "",
            image: buildImage("assets/intro_screen/2.gif"),
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: "",
            body: "",
            image: buildImage("assets/intro_screen/3.gif"),
            decoration: getPageDecoration(),
          ),
        ],
        onDone: () => onDone(context),
        //ClampingScrollPhysics prevent the scroll offset from exceeding the bounds of the content.
        scrollPhysics: const ClampingScrollPhysics(),
        showDoneButton: true,
        showNextButton: true,
        showSkipButton: true,
        //isBottomSafeArea: true,
        skip:
            const Text("Salta", style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.forward),
        done:
            const Text("Finito!", style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: getDotsDecorator()
      ),
    );
  }

  //widget to add the image on screen
  Widget buildImage(String imagePath) {
    return Center(
      child: Gif(
        image: AssetImage(
          imagePath
        ),
        autostart: Autostart.once,
      )
    );
  }

  //method to customise the page style
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
      ) 
    );
  }

  //method to customize the dots style
  DotsDecorator getDotsDecorator() {
    return const DotsDecorator(
      spacing: EdgeInsets.symmetric(horizontal: 2),
      activeColor: Colors.indigo,
      color: Colors.grey,
      activeSize: Size(12, 5),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }
}