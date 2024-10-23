import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/services/storage/base_storage.dart';
import 'package:web_dex/services/storage/get_storage.dart';

class WalletsRepo {
  WalletsRepo({required BaseStorage storage}) : _storage = storage;
  final BaseStorage _storage;

  Future<List<Wallet>> getAll() async {
    final List<Map<String, dynamic>> json =
        (await _storage.read(allWalletsStorageKey) as List?)
                ?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[];
    final List<Wallet> wallets =
        json.map((Map<String, dynamic> w) => Wallet.fromJson(w)).toList();

    return wallets;
  }

  Future<bool> save(Wallet wallet) async {
    final wallets = await getAll();
    final int walletIndex = wallets.indexWhere((w) => w.id == wallet.id);

    if (walletIndex == -1) {
      wallets.add(wallet);
    } else {
      wallets[walletIndex] = wallet;
    }

    return _write(wallets);
  }

  Future<bool> delete(Wallet wallet) async {
    final wallets = await getAll();
    wallets.removeWhere((w) => w.id == wallet.id);
    return _write(wallets);
  }

  Future<bool> _write(List<Wallet> wallets) {
    return _storage.write(allWalletsStorageKey, wallets);
  }
}

final WalletsRepo walletsRepo = WalletsRepo(storage: getStorage());
