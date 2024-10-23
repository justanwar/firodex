import 'package:web_dex/shared/utils/encryption_tool.dart';

class Wallet {
  Wallet({
    required this.id,
    required this.name,
    required this.config,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        config: WalletConfig.fromJson(json['config']),
      );

  String id;
  String name;
  WalletConfig config;

  bool get isHW => config.type != WalletType.iguana;

  Future<String> getSeed(String password) async =>
      await EncryptionTool().decryptData(password, config.seedPhrase) ?? '';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'config': config.toJson(),
      };

  Wallet copy() {
    return Wallet(
      id: id,
      name: name,
      config: config.copy(),
    );
  }
}

class WalletConfig {
  WalletConfig({
    required this.seedPhrase,
    this.pubKey,
    required this.activatedCoins,
    required this.hasBackup,
    this.type = WalletType.iguana,
  });

  factory WalletConfig.fromJson(Map<String, dynamic> json) {
    return WalletConfig(
      type: WalletType.fromJson(json['type'] ?? WalletType.iguana.name),
      seedPhrase: json['seed_phrase'],
      pubKey: json['pub_key'],
      activatedCoins:
          List<String>.from(json['activated_coins'] ?? <String>[]).toList(),
      hasBackup: json['has_backup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'seed_phrase': seedPhrase,
      'pub_key': pubKey,
      'activated_coins': activatedCoins,
      'has_backup': hasBackup,
    };
  }

  String seedPhrase;
  String? pubKey;
  List<String> activatedCoins;
  bool hasBackup;
  WalletType type;

  WalletConfig copy() {
    return WalletConfig(
      activatedCoins: [...activatedCoins],
      hasBackup: hasBackup,
      type: type,
      seedPhrase: seedPhrase,
      pubKey: pubKey,
    );
  }
}

enum WalletType {
  iguana,
  trezor,
  metamask,
  keplr;

  factory WalletType.fromJson(String json) {
    switch (json) {
      case 'trezor':
        return WalletType.trezor;
      case 'metamask':
        return WalletType.metamask;
      case 'keplr':
        return WalletType.keplr;
      default:
        return WalletType.iguana;
    }
  }
}
