// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_dex/main.dart' as app;

import '../../common/goto.dart' as goto;
import '../../common/pause.dart';
import '../../common/tester_utils.dart';
import '../../helpers/accept_alpha_warning.dart';
import '../../helpers/restore_wallet.dart';
import 'wallet_tools.dart';

Future<void> testActivateCoins(WidgetTester tester) async {
  await pause(sec: 2, msg: 'TEST COINS ACTIVATION');

  const String ethByTicker = 'ETH';
  const String dogeByName = 'gecoi';
  const String kmdBep20ByTicker = 'KMD';

  final Finder totalAmount = find.byKey(
    const Key('overview-total-balance'),
  );
  final Finder ethCoinItem = find.byKey(
    const Key('coins-manager-list-item-eth'),
  );
  final Finder dogeCoinItem = find.byKey(
    const Key('coins-manager-list-item-doge'),
  );
  final Finder kmdBep20CoinItem = find.byKey(
    const Key('coins-manager-list-item-kmd-bep20'),
  );

  await goto.walletPage(tester);
  expect(totalAmount, findsOneWidget);

  await _testNoneExistCoin(tester);
  await addAsset(tester, asset: dogeCoinItem, search: dogeByName);
  await addAsset(tester, asset: kmdBep20CoinItem, search: kmdBep20ByTicker);
  await removeAsset(tester, asset: ethCoinItem, search: ethByTicker);
  await removeAsset(tester, asset: dogeCoinItem, search: dogeByName);
  await removeAsset(tester, asset: kmdBep20CoinItem, search: kmdBep20ByTicker);
  await goto.dexPage(tester);
  await goto.walletPage(tester);
  await pause(msg: 'END TEST COINS ACTIVATION');
}

// Try to find non-existent coin
Future<void> _testNoneExistCoin(WidgetTester tester) async {
  final Finder addAssetsButton = find.byKey(
    const Key('add-assets-button'),
  );
  final Finder searchCoinsField = find.byKey(
    const Key('coins-manager-search-field'),
  );
  final Finder ethCoinItem = find.byKey(
    const Key('coins-manager-list-item-eth'),
  );

  await goto.walletPage(tester);
  await testerTap(tester, addAssetsButton);
  expect(searchCoinsField, findsOneWidget);

  await enterText(tester, finder: searchCoinsField, text: 'NOSUCHCOINEVER');
  expect(ethCoinItem, findsNothing);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Run coins activation tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    await app.main();
    await tester.pumpAndSettle();
    print('ACCEPT ALPHA WARNING');
    await acceptAlphaWarning(tester);
    await restoreWalletToTest(tester);
    await testActivateCoins(tester);
    await tester.pumpAndSettle();

    print('END COINS ACTIVATION TESTS');
  }, semanticsEnabled: false);
}
