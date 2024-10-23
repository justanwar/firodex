import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> acceptAlphaWarning(WidgetTester tester) async {
  final Finder button = find.byKey(const Key('accept-alpha-warning-button'));
  final alphaWarningExists = tester.any(button);
  if (alphaWarningExists) {
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }
}
