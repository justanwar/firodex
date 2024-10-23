import 'package:flutter_test/flutter_test.dart';

import 'pause.dart';

Future<void> testerTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await pause();
}

Future<bool> isWidgetVisible(WidgetTester tester, Finder finder) async {
  try {
    await tester.pumpAndSettle();
    expect(finder, findsOneWidget);
    return true;
  } catch (e) {
    return false;
  }
}
