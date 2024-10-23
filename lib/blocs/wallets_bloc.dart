import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/wallets_bloc/wallets_repo.dart';
import 'package:web_dex/blocs/bloc_base.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/shared/utils/encryption_tool.dart';
import 'package:web_dex/shared/utils/utils.dart';

class WalletsBloc implements BlocBase {
  WalletsBloc({
    required WalletsRepo walletsRepo,
    required EncryptionTool encryptionTool,
  })  : _walletsRepo = walletsRepo,
        _encryptionTool = encryptionTool;

  final WalletsRepo _walletsRepo;
  final EncryptionTool _encryptionTool;

  List<Wallet> _wallets = <Wallet>[];
  List<Wallet> get wallets => _wallets;
  set wallets(List<Wallet> newWallets) {
    _wallets = newWallets;
    _inWallets.add(_wallets);
  }

  final StreamController<List<Wallet>> _walletsController =
      StreamController<List<Wallet>>.broadcast();
  Sink<List<Wallet>> get _inWallets => _walletsController.sink;
  Stream<List<Wallet>> get outWallets => _walletsController.stream;

  @override
  void dispose() {
    _walletsController.close();
  }

  Future<Wallet?> createNewWallet({
    required String name,
    required String password,
    required String seed,
  }) async {
    try {
      bool isWalletCreationSuccessfully = false;

      final String encryptedSeed =
          await _encryptionTool.encryptData(password, seed);

      final Wallet newWallet = Wallet(
        id: const Uuid().v1(),
        name: name,
        config: WalletConfig(
          type: WalletType.iguana,
          seedPhrase: encryptedSeed,
          activatedCoins: enabledByDefaultCoins,
          hasBackup: false,
        ),
      );
      log('Creating a new wallet ${newWallet.id}',
          path: 'wallet_bloc => createNewWallet');

      isWalletCreationSuccessfully = await _addWallet(newWallet);

      if (isWalletCreationSuccessfully) {
        log('The wallet ${newWallet.id} has created',
            path: 'wallet_bloc => createNewWallet');
        return newWallet;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<Wallet?> importWallet({
    required String name,
    required String password,
    required WalletConfig walletConfig,
    WalletType type = WalletType.iguana,
  }) async {
    log('Importing a wallet $name', path: 'wallet_bloc => importWallet');
    try {
      bool isWalletCreationSuccessfully = false;

      final String encryptedSeed =
          await _encryptionTool.encryptData(password, walletConfig.seedPhrase);
      final Wallet newWallet = Wallet(
        id: const Uuid().v1(),
        name: name,
        config: WalletConfig(
          type: type,
          seedPhrase: encryptedSeed,
          activatedCoins: walletConfig.activatedCoins,
          hasBackup: true,
        ),
      );

      isWalletCreationSuccessfully = await _addWallet(newWallet);

      if (isWalletCreationSuccessfully) {
        log('The Wallet $name has imported',
            path: 'wallet_bloc => importWallet');
        return newWallet;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<Wallet?> importTrezorWallet({
    required String name,
    required String pubKey,
  }) async {
    try {
      final Wallet? existedWallet =
          wallets.firstWhereOrNull((w) => w.config.pubKey == pubKey);
      if (existedWallet != null) return existedWallet;

      final Wallet newWallet = Wallet(
        id: const Uuid().v1(),
        name: name,
        config: WalletConfig(
          type: WalletType.trezor,
          seedPhrase: '',
          activatedCoins: enabledByDefaultTrezorCoins,
          hasBackup: true,
          pubKey: pubKey,
        ),
      );

      final bool isWalletImportSuccessfully = await _addWallet(newWallet);

      if (isWalletImportSuccessfully) {
        log('The Wallet $name has imported',
            path: 'wallet_bloc => importWallet');
        return newWallet;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchSavedWallets() async {
    wallets = await _walletsRepo.getAll();
  }

  Future<bool> deleteWallet(Wallet wallet) async {
    log(
      'Deleting a wallet ${wallet.id}',
      path: 'wallet_bloc => deleteWallet',
    );

    final bool isDeletingSuccess = await _walletsRepo.delete(wallet);
    if (isDeletingSuccess) {
      final newWallets = _wallets.where((w) => w.id != wallet.id).toList();
      wallets = newWallets;
      log(
        'The wallet ${wallet.id} has deleted',
        path: 'wallet_bloc => deleteWallet',
      );
    }

    return isDeletingSuccess;
  }

  Future<bool> _addWallet(Wallet wallet) async {
    final bool isSavingSuccess = await _walletsRepo.save(wallet);
    if (isSavingSuccess) {
      final List<Wallet> newWallets = [..._wallets];
      newWallets.add(wallet);
      wallets = newWallets;
    }

    return isSavingSuccess;
  }

  String? validateWalletName(String name) {
    if (wallets.firstWhereOrNull((w) => w.name == name) != null) {
      return LocaleKeys.walletCreationExistNameError.tr();
    } else if (name.isEmpty || name.length > 40) {
      return LocaleKeys.walletCreationNameLengthError.tr();
    }
    return null;
  }

  Future<void> resetSpecificWallet(Wallet wallet) async {
    WalletConfig updatedConfig = wallet.config.copy()
      ..activatedCoins = enabledByDefaultCoins;

    Wallet updatedWallet = Wallet(
      id: wallet.id,
      name: wallet.name,
      config: updatedConfig,
    );

    await _walletsRepo.save(updatedWallet);
  }
}
