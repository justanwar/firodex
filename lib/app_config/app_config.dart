import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const String mmRpcVersion = '2.0';
// issue https://github.com/flutter/flutter/issues/19462#issuecomment-478284020
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
const double maxScreenWidth = 1273;
const double mainLayoutPadding = 29;
const double appBarHeight = 70;
const int scaleOnInfinitePrecision = 20; // ETH has 18 decimals, so use more
const String allWalletsStorageKey = 'all-wallets';
const String defaultDexCoin = 'FIRO';
const List<Locale> localeList = [Locale('en')];
const String assetsPath = 'assets';
const String coinsAssetsPath = 'packages/komodo_defi_framework/assets';

final Uri discordSupportChannelUrl = Uri.parse(
    'https://discord.com/channels/412898016371015680/429676282196787200');
final Uri discordInviteUrl = Uri.parse('https://komodoplatform.com/discord');

/// Const to define if Bitrefill integration is enabled in the app.
const bool isBitrefillIntegrationEnabled = false;

/// Const to define whether to show trading warning dialogs and notices.
/// This can be used to control the display of trading-related warnings
/// throughout the application.
///
///! You are solely responsible for any losses/damage that may occur due to
///! compliance issues, bugs, or other unforeseen circumstances. Komodo
///! Platform and its legal entities do not condone the use of this app for
///! trading purposes where it is not legally compliant.
const bool kShowTradingWarning = false;

const Duration kPerformanceLogInterval = Duration(minutes: 1);

// This information is here because it is not contextual and is branded.
// Names of their own are not localized. Also, the application is initialized before
// the localization package is initialized.
String get appTitle => 'FiroDEX Wallet | Non-Custodial Multi-Coin Wallet & DEX';
String get appShortTitle => 'FiroDEX Wallet';

Map<String, int> priorityCoinsAbbrMap = {
  'FIRO': 30,
  'KMD': 20,
  'BTC-segwit': 20,
  'ETH': 20,
  'LTC-segwit': 20,
  'USDT-ERC20': 20,
  'USDT-PLG20': 20,
  'BNB': 11,
  'ETC': 11,
  'DOGE': 11,
  'DASH': 11,
  'MATIC': 10,
  'FTM': 10,
  'ARB': 10,
  'AVAX': 10,
  'HT': 10,
  'MOVR': 10,
};

/// List of coins that are excluded from the list of coins displayed on the
/// coin lists (e.g. wallet page, coin selection dropdowns, etc.)
const Set<String> excludedAssetList = {
  'ADEXBSCT',
  'ADEXBSC',
  'BRC',
  'WID',
  'EPC',
  'CFUN',
  'ENT',
  'PLY',
  'ILNSW-PLG20',
  'FENIX',
  'AWR',
  'BOT',
  // Pirate activation params are not yet implemented, so we need to
  // exclude it from the list of coins for now.
  'ARRR',
  'ZOMBIE',
  'SMTF-v2',
  'SFUSD',
  'VOTE2023',
  'RICK',
  'MORTY',

  // NFT v2 coins: https://github.com/KomodoPlatform/coins/pull/1061 will be
  // used in the background, so users do not need to see them.
  'NFT_ETH',
  'NFT_AVAX',
  'NFT_BNB',
  'NFT_FTM',
  'NFT_MATIC',
};

const List<String> excludedAssetListTrezor = [
  // https://github.com/KomodoPlatform/atomicDEX-API/issues/1510
  'BCH',
  // https://github.com/KomodoPlatform/coins/pull/619/files
  // Can't use modified config directly, since it includes features,
  // not implemented on webdex side yet (e.g. 0.4.2 doesn't have segwit)
  'VAL',
];

/// Some coins returned by the Banxa API are returning errors when attempting
/// to create an order. This is a temporary workaround to filter out those coins
/// until the issue is resolved.
const banxaUnsupportedCoinsList = [
  'APE', // chain not configured for APE
  'AVAX', // avax & bep20 - invalid wallet address error
  'DOT', // bep20 - invalid wallet address error
  'FIL', // bep20 - invalid wallet address error
  'ONE', // invalid wallet address error (one**** (native) format expected)
  'TON', // erc20 - invalid wallet address error
  'TRX', // bep20 - invalid wallet address error
  'XML', // invalid wallet address error
];

const rampUnsupportedCoinsList = [
  'ONE', // invalid wallet address error (one**** format expected)
];

// Assets in wallet-only mode on app level,
// global wallet-only assets are defined in coins config files.
const List<String> appWalletOnlyAssetList = [
  'BET',
  'BOTS',
  'CRYPTO',
  'DEX',
  'HODL',
  'JUMBLR',
  'MGW',
  'MSHARK',
  'PANGEA',
  'REVS',
  'SUPERNET',
];

/// Coins that are enabled by default on restore from seed or registration.
/// This will not affect existing wallets.
List<String> get enabledByDefaultCoins => [
      'BTC-segwit',
      'FIRO',
      'USDT-PLG20',
      'KMD',
      'LTC-segwit',
      'ETH',
      'MATIC',
      'BNB',
      'AVAX',
      'FTM',
      if (kDebugMode) 'DOC',
      if (kDebugMode) 'MARTY',
    ];

List<String> get enabledByDefaultTrezorCoins => [
      'BTC',
      'KMD',
      'LTC',
    ];

List<String> get coinsWithFaucet => ['RICK', 'MORTY', 'DOC', 'MARTY'];

const String logsDbName = 'logs';
const String appFolder = 'KomodoWallet';

Future<String> get applicationDocumentsDirectory async => kIsWeb
    ? appFolder
    : '${(await getApplicationDocumentsDirectory()).path}/$appFolder';
