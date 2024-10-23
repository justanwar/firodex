import 'dart:async';
import 'dart:convert';

import 'package:web_dex/bloc/auth_bloc/auth_repository.dart';
import 'package:web_dex/bloc/wallets_bloc/wallets_repo.dart';
import 'package:web_dex/blocs/bloc_base.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/services/file_loader/file_loader.dart';
import 'package:web_dex/shared/utils/encryption_tool.dart';

class CurrentWalletBloc implements BlocBase {
  CurrentWalletBloc({
    required EncryptionTool encryptionTool,
    required FileLoader fileLoader,
    required WalletsRepo walletsRepo,
    required AuthRepository authRepo,
  })  : _encryptionTool = encryptionTool,
        _fileLoader = fileLoader,
        _walletsRepo = walletsRepo;

  final EncryptionTool _encryptionTool;
  final FileLoader _fileLoader;
  final WalletsRepo _walletsRepo;
  late StreamSubscription<AuthorizeMode> _authModeListener;

  final StreamController<Wallet?> _walletController =
      StreamController<Wallet?>.broadcast();
  Sink<Wallet?> get _inWallet => _walletController.sink;
  Stream<Wallet?> get outWallet => _walletController.stream;

  Wallet? _wallet;
  Wallet? get wallet => _wallet;
  set wallet(Wallet? wallet) {
    _wallet = wallet;
    _inWallet.add(_wallet);
  }

  @override
  void dispose() {
    _walletController.close();
    _authModeListener.cancel();
  }

  Future<bool> updatePassword(
      String oldPassword, String password, Wallet wallet) async {
    final walletCopy = wallet.copy();

    final String? decryptedSeed = await _encryptionTool.decryptData(
        oldPassword, walletCopy.config.seedPhrase);
    final String encryptedSeed =
        await _encryptionTool.encryptData(password, decryptedSeed!);
    walletCopy.config.seedPhrase = encryptedSeed;
    final bool isSaved = await _walletsRepo.save(walletCopy);

    if (isSaved) {
      this.wallet = walletCopy;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addCoin(Coin coin) async {
    final String coinAbbr = coin.abbr;
    final Wallet? wallet = this.wallet;
    if (wallet == null) {
      return false;
    }
    if (wallet.config.activatedCoins.contains(coinAbbr)) {
      return false;
    }
    wallet.config.activatedCoins.add(coinAbbr);

    final bool isSuccess = await _walletsRepo.save(wallet);
    return isSuccess;
  }

  Future<bool> removeCoin(String coinAbbr) async {
    final Wallet? wallet = this.wallet;
    if (wallet == null) {
      return false;
    }

    wallet.config.activatedCoins.remove(coinAbbr);
    final bool isSuccess = await _walletsRepo.save(wallet);
    this.wallet = wallet;
    return isSuccess;
  }

  Future<void> downloadCurrentWallet(String password) async {
    final Wallet? wallet = this.wallet;
    if (wallet == null) return;

    final String data = jsonEncode(wallet.config);
    final String encryptedData =
        await _encryptionTool.encryptData(password, data);

    _fileLoader.save(
      fileName: wallet.name,
      data: encryptedData,
      type: LoadFileType.text,
    );

    await confirmBackup();
    this.wallet = wallet;
  }

  Future<void> confirmBackup() async {
    final Wallet? wallet = this.wallet;
    if (wallet == null || wallet.config.hasBackup) return;

    wallet.config.hasBackup = true;
    await _walletsRepo.save(wallet);
    this.wallet = wallet;
  }
}
