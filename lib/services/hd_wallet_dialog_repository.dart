import 'package:web_dex/services/storage/base_storage.dart';
import 'package:web_dex/services/storage/get_storage.dart';

/// Service for storing whether HD wallet mode dialogs have been shown.
class HdWalletDialogRepository {
  HdWalletDialogRepository() : _storage = getStorage();

  final BaseStorage _storage;

  String _legacyKey(String walletName) =>
      'hd_offer_shown_${walletName.toLowerCase()}';

  String _hdKey(String walletName) =>
      'hd_warning_shown_${walletName.toLowerCase()}';

  Future<bool> isLegacyDialogShown(String walletName) async {
    return await _storage.read(_legacyKey(walletName)) ?? false;
  }

  Future<void> setLegacyDialogShown(String walletName) async {
    await _storage.write(_legacyKey(walletName), true);
  }

  Future<bool> isHdDialogShown(String walletName) async {
    return await _storage.read(_hdKey(walletName)) ?? false;
  }

  Future<void> setHdDialogShown(String walletName) async {
    await _storage.write(_hdKey(walletName), true);
  }
}
