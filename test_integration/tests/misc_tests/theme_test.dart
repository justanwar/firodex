// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_dex/main.dart' as app;

import '../../common/goto.dart' as goto;
import '../../helpers/accept_alpha_warning.dart';

Future<void> testThemeSwitcher(WidgetTester tester) async {
  final themeSwitcherFinder = find.byKey(const Key('theme-switcher'));
  final themeSettingsSwitcherLight =
      find.byKey(const Key('theme-settings-switcher-Light'));
  final themeSettingsSwitcherDark =
      find.byKey(const Key('theme-settings-switcher-Dark'));

  // Check default theme (dark)
  checkTheme(tester, themeSwitcherFinder, Brightness.dark);

  await tester.tap(themeSwitcherFinder);
  await tester.pumpAndSettle();
  checkTheme(tester, themeSwitcherFinder, Brightness.light);

  await goto.settingsPage(tester);
  await tester.tap(themeSettingsSwitcherDark);
  await tester.pumpAndSettle();
  checkTheme(tester, themeSwitcherFinder, Brightness.dark);

  await tester.pumpAndSettle();
  await tester.tap(themeSettingsSwitcherLight);
  await tester.pumpAndSettle();
  checkTheme(tester, themeSwitcherFinder, Brightness.light);
}

dynamic checkTheme(
    WidgetTester tester, Finder testElement, Brightness brightnessExpected) {
  expect(Theme.of(tester.element(testElement)).brightness,
      equals(brightnessExpected));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run design tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    await app.main();
    await tester.pumpAndSettle();
    await acceptAlphaWarning(tester);
    print('ACCEPT ALPHA WARNING');
    await tester.pumpAndSettle();
    await testThemeSwitcher(tester);

    print('END THEME SWITCH TESTS');
  }, semanticsEnabled: false);
}
