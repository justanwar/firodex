// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/main.dart' as app;
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/shared/widgets/coin_icon.dart';

import '../../helpers/accept_alpha_warning.dart';
import '../../helpers/restore_wallet.dart';

Future<void> testCoinIcons(WidgetTester tester) async {
  final Finder walletTab = find.byKey(const Key('main-menu-wallet'));
  final Finder addAssetsButton = find.byKey(const Key('add-assets-button'));

  await tester.tap(walletTab);
  await tester.pumpAndSettle();
  await tester.tap(addAssetsButton);
  await tester.pumpAndSettle();

  final listFinder = find.byKey(const Key('coins-manager-list'));

  // Get the size of the list
  bool keepScrolling = true;
  // Scroll down the list until we reach the end
  while (keepScrolling) {
    // Check the icons before scrolling
    final coinIcons = find
        .descendant(of: listFinder, matching: find.byType(CoinIcon))
        .evaluate()
        .map((e) => e.widget as CoinIcon);

    for (final coinIcon in coinIcons) {
      final coinAbr = abbr2Ticker(coinIcon.coinAbbr).toLowerCase();
      final assetPath = '$assetsPath/coin_icons/png/$coinAbr.png';
      final assetExists = await canLoadAsset(assetPath);
      expect(assetExists, true, reason: 'Asset $assetPath does not exist');
    }

    // Scoll the list
    await tester.drag(listFinder, const Offset(0, -500));
    await tester.pumpAndSettle();

    // Check if we reached the end of the list
    final scrollable = listFinder.evaluate().first.widget as ListView;
    final currentPosition = scrollable.controller!.position.pixels;
    final maxScrollExtent = scrollable.controller!.position.maxScrollExtent;
    keepScrolling = currentPosition < maxScrollExtent;
  }
}

Future<bool> canLoadAsset(String assetPath) async {
  bool assetExists = true;
  try {
    final _ = await rootBundle.load(assetPath);
  } catch (e) {
    assetExists = false;
  }
  return assetExists;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Run coin icons tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    await app.main();
    await tester.pumpAndSettle();
    print('ACCEPT ALPHA WARNING');
    await acceptAlphaWarning(tester);
    await restoreWalletToTest(tester);
    await testCoinIcons(tester);
    await tester.pumpAndSettle();

    print('END COINS ICONS TESTS');
  }, semanticsEnabled: false);
}
