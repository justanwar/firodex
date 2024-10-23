// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_dex/main.dart' as app;

import './wallets_manager_create_test.dart';
import './wallets_manager_import_test.dart';
import '../../helpers/accept_alpha_warning.dart';
import '../../helpers/log_out.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Run wallet manager tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    await app.main();
    await tester.pumpAndSettle();
    await acceptAlphaWarning(tester);
    await tester.pumpAndSettle();
    await testCreateWallet(tester);
    await tester.pumpAndSettle();
    await logOut(tester);
    await tester.pumpAndSettle();
    await testImportWallet(tester);

    print('END WALLET MANAGER TESTS');
  }, semanticsEnabled: false);
}
