// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:insigno_frontend/networking/data/pill.dart';
import 'package:insigno_frontend/page/pill_page.dart';

void main() {
  testWidgets("Pill page test", (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(PillPage(Pill(99, "Text", "Author", "https://example.com", true)));

    expect(find.text("Text"), findsOneWidget);
    expect(find.text("Author"), findsOneWidget);
    expect(find.text("https://example.com"), findsOneWidget);
    expect(find.text("99"), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.text(""));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
