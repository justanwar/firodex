import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_dex/common/screen_type.dart';

import 'tester_utils.dart';

Future<void> walletPage(WidgetTester tester, {ScreenType? type}) async {
  return await _go(find.byKey(const Key('main-menu-wallet')), tester);
}

Future<void> dexPage(WidgetTester tester, {ScreenType? type}) async {
  return await _go(find.byKey(const Key('main-menu-dex')), tester);
}

Future<void> bridgePage(WidgetTester tester, {ScreenType? type}) async {
  return await _go(find.byKey(const Key('main-menu-bridge')), tester);
}

Future<void> nftsPage(WidgetTester tester, {ScreenType? type}) async {
  return await _go(find.byKey(const Key('main-menu-nft')), tester);
}

Future<void> settingsPage(WidgetTester tester, {ScreenType? type}) async {
  await _go(find.byKey(const Key('main-menu-settings')), tester);
}

Future<void> supportPage(WidgetTester tester, {ScreenType? type}) async {
  return await _go(find.byKey(const Key('main-menu-support')), tester);
}

Future<void> _go(Finder finder, WidgetTester tester) async {
  expect(finder, findsOneWidget, reason: 'goto.dart _go($finder)');
  await testerTap(tester, finder);
  await tester.pumpAndSettle();
}
