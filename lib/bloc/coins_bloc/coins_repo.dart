import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart' as coin_updates;
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/app_config/coins_config_parser.dart';
import 'package:web_dex/bloc/runtime_coin_updates/runtime_update_config_provider.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/convert_address/convert_address_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/electrum/electrum_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/enable/enable_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/enable_tendermint/enable_tendermint_token.dart';
import 'package:web_dex/mm2/mm2_api/rpc/enable_tendermint/enable_tendermint_with_assets.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_maker_vol/max_maker_vol_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/send_raw_transaction/send_raw_transaction_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/send_raw_transaction/send_raw_transaction_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/withdraw/withdraw_request.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_type.dart';
import 'package:web_dex/model/text_error.dart';

final CoinsRepo coinsRepo = CoinsRepo(
  api: mm2Api,
);

class CoinsRepo {
  CoinsRepo({
    required Mm2Api api,
  }) : _api = api;
  final Mm2Api _api;
  coin_updates.CoinConfigRepository? _coinRepo;

  List<Coin>? _cachedKnownCoins;

  // TODO: Consider refactoring to a Map
  Future<List<Coin>> getKnownCoins() async {
    if (_cachedKnownCoins != null) return _cachedKnownCoins!;

    _coinRepo ??= coin_updates.CoinConfigRepository.withDefaults(
      await RuntimeUpdateConfigProvider().getRuntimeUpdateConfig(),
    );
    // If the bundled config files don't exist, then download the latest configs
    // and load them from the storage provider.
    final bool bundledConfigsExist = await coinConfigParser.hasLocalConfigs();
    if (!bundledConfigsExist) {
      await _coinRepo!.updateCoinConfig(excludedAssets: excludedAssetList);
    }

    final bool hasUpdatedConfigs = await _coinRepo!.coinConfigExists();
    if (!bundledConfigsExist || hasUpdatedConfigs) {
      final coins = await _getKnownCoinsFromStorage();
      if (coins.isNotEmpty) {
        _cachedKnownCoins = coins;
        return coins;
      }
    }

    final coins = _cachedKnownCoins ?? await _getKnownCoinsFromConfig();
    return [...coins];
  }

  /// Get the list of [coin_updates.Coin]s with the minimal fields from `coins.json`.
  /// If the local coin configs exist, and there are no updates in storage, then
  /// the coins from the bundled configs are loaded.
  /// Otherwise, the coins from storage are loaded.
  Future<List<coin_updates.Coin>> getKnownGlobalCoins() async {
    _coinRepo ??= coin_updates.CoinConfigRepository.withDefaults(
      await RuntimeUpdateConfigProvider().getRuntimeUpdateConfig(),
    );

    final bool bundledConfigsExist = await coinConfigParser.hasLocalConfigs();
    if (!bundledConfigsExist) {
      await _coinRepo!.updateCoinConfig(excludedAssets: excludedAssetList);
    }

    final bool hasUpdatedConfigs = await _coinRepo!.coinConfigExists();
    if (!bundledConfigsExist || hasUpdatedConfigs) {
      final coins =
          await _coinRepo!.getCoins(excludedAssets: excludedAssetList);
      if (coins != null && coins.isNotEmpty) {
        return coins
            .where((coin) => !excludedAssetList.contains(coin.coin))
            .toList();
      }
    }

    final globalCoins = await coinConfigParser.getGlobalCoinsJson();
    return globalCoins
        .map((coin) => coin_updates.Coin.fromJson(coin as Map<String, dynamic>))
        .toList();
  }

  /// Loads the known [coin_updates.Coin]s from the storage provider, maps it
  /// to the existing [Coin] model with the parent coin assigned and
  /// orphans removed.
  Future<List<Coin>> _getKnownCoinsFromStorage() async {
    final List<Coin> coins =
        (await _coinRepo!.getCoinConfigs(excludedAssets: excludedAssetList))!
            .values
            .where((coin) => getCoinType(coin.type ?? '', coin.coin) != null)
            .where((coin) => !_shouldSkipCoin(coin))
            .map(_mapCoinConfigToCoin)
            .toList();

    for (Coin coin in coins) {
      coin.parentCoin = _getParentCoin(coin, coins);
    }

    _removeOrphans(coins);

    final List<Coin> unmodifiableCoins = List.unmodifiable(coins);
    _cachedKnownCoins = unmodifiableCoins;
    return unmodifiableCoins;
  }

  /// Maps the komodo_coin_updates package Coin class [coin]
  /// to the app Coin class.
  Coin _mapCoinConfigToCoin(coin_updates.CoinConfig coin) {
    final coinJson = coin.toJson();
    coinJson['abbr'] = coin.coin;
    coinJson['priority'] = priorityCoinsAbbrMap[coin.coin] ?? 0;
    coinJson['active'] = enabledByDefaultCoins.contains(coin.coin);
    if (kIsWeb) {
      coinConfigParser.removeElectrumsWithoutWss(coinJson['electrum']);
    }
    final newCoin = Coin.fromJson(coinJson, coinJson);
    return newCoin;
  }

  /// Checks if the coin should be skipped according to the following rules:
  /// - If the coin is in the excluded asset list.
  /// - If the coin type is not supported or empty.
  /// - If the electrum servers are not supported on the current platform
  ///   (WSS on web, SSL and TCP on native platforms).
  bool _shouldSkipCoin(coin_updates.CoinConfig coin) {
    if (excludedAssetList.contains(coin.coin)) {
      return true;
    }

    if (getCoinType(coin.type, coin.coin) == null) {
      return true;
    }

    if (coin.electrum != null && coin.electrum?.isNotEmpty == true) {
      return coin.electrum!
          .every((e) => !_isConnectionTypeSupported(e.protocol ?? ''));
    }

    return false;
  }

  /// Returns true if [networkProtocol] is supported on the current platform.
  /// On web, only WSS is supported.
  /// On other (native) platforms, only SSL and TCP are supported.
  bool _isConnectionTypeSupported(String networkProtocol) {
    String uppercaseProtocol = networkProtocol.toUpperCase();

    if (kIsWeb) {
      return uppercaseProtocol == 'WSS';
    }

    return uppercaseProtocol == 'SSL' || uppercaseProtocol == 'TCP';
  }

  Future<List<Coin>> _getKnownCoinsFromConfig() async {
    final List<dynamic> globalCoinsJson =
        await coinConfigParser.getGlobalCoinsJson();
    final Map<String, dynamic> appCoinsJson =
        await coinConfigParser.getUnifiedCoinsJson();

    final List<dynamic> appItems = appCoinsJson.values.toList();

    _removeUnknown(appItems, globalCoinsJson);

    final List<Coin> coins = appItems.map<Coin>((dynamic appItem) {
      final dynamic globalItem =
          _getGlobalItemByAbbr(appItem['coin'], globalCoinsJson);

      return Coin.fromJson(appItem, globalItem);
    }).toList();

    for (Coin coin in coins) {
      coin.parentCoin = _getParentCoin(coin, coins);
    }

    _removeOrphans(coins);

    final List<Coin> unmodifiableCoins = List.unmodifiable(coins);
    _cachedKnownCoins = unmodifiableCoins;
    return unmodifiableCoins;
  }

  // 'Orphans' are coins that have 'parent' coin in config,
  // but 'parent' coin wasn't found.
  void _removeOrphans(List<Coin> coins) {
    final List<Coin> original = List.from(coins);

    coins.removeWhere((coin) {
      final String? platform = coin.protocolData?.platform;
      if (platform == null) return false;

      final parentCoin =
          original.firstWhereOrNull((coin) => coin.abbr == platform);

      return parentCoin == null;
    });
  }

  void _removeUnknown(
    List<dynamic> appItems,
    List<dynamic> globalItems,
  ) {
    appItems.removeWhere((dynamic appItem) {
      return _getGlobalItemByAbbr(appItem['coin'], globalItems) == null;
    });
  }

  dynamic _getGlobalItemByAbbr(String abbr, List<dynamic> globalItems) {
    return globalItems.firstWhereOrNull((dynamic item) => abbr == item['coin']);
  }

  Coin? _getParentCoin(Coin? coin, List<Coin> coins) {
    final String? parentCoinAbbr = coin?.protocolData?.platform;
    if (parentCoinAbbr == null) return null;

    return coins.firstWhereOrNull(
        (item) => item.abbr.toUpperCase() == parentCoinAbbr.toUpperCase());
  }

  Future<List<Coin>> getEnabledCoins(List<Coin> knownCoins) async {
    final enabledCoins = await _api.getEnabledCoins(knownCoins);
    return enabledCoins ?? [];
  }

  Future<MaxMakerVolResponse?> getBalanceInfo(String abbr) async {
    return await _api.getMaxMakerVol(abbr);
  }

  Future<void> deactivateCoin(Coin coin) async {
    await _api.disableCoin(coin.abbr);
  }

  Future<Map<String, dynamic>?> validateCoinAddress(
      Coin coin, String address) async {
    return await _api.validateAddress(coin.abbr, address);
  }

  Future<Map<String, dynamic>?> withdraw(WithdrawRequest request) async {
    return await _api.withdraw(request);
  }

  Future<SendRawTransactionResponse> sendRawTransaction(
      SendRawTransactionRequest request) async {
    final response = await _api.sendRawTransaction(request);
    if (response == null) {
      return SendRawTransactionResponse(
        txHash: null,
        error: TextError(error: LocaleKeys.somethingWrong.tr()),
      );
    }

    return SendRawTransactionResponse.fromJson(response);
  }

  Future<void> activateCoins(List<Coin> coins) async {
    final List<EnableEthWithTokensRequest> ethWithTokensRequests = [];
    final List<EnableErc20Request> erc20Requests = [];
    final List<ElectrumReq> electrumCoinRequests = [];
    final List<EnableTendermintWithAssetsRequest> tendermintRequests = [];
    final List<EnableTendermintTokenRequest> tendermintTokenRequests = [];
    final List<EnableBchWithTokens> bchWithTokens = [];
    final List<EnableSlp> slpTokens = [];

    for (Coin coin in coins) {
      if (coin.type == CoinType.cosmos || coin.type == CoinType.iris) {
        if (coin.isIrisToken) {
          tendermintTokenRequests
              .add(EnableTendermintTokenRequest(ticker: coin.abbr));
        } else {
          tendermintRequests.add(EnableTendermintWithAssetsRequest(
            ticker: coin.abbr,
            rpcUrls: coin.rpcUrls,
          ));
        }
      } else if (coin.type == CoinType.slp) {
        slpTokens.add(EnableSlp(ticker: coin.abbr));
      } else if (coin.protocolType == 'BCH') {
        bchWithTokens.add(EnableBchWithTokens(
            ticker: coin.abbr, servers: coin.electrum, urls: coin.bchdUrls));
      } else if (coin.electrum.isNotEmpty) {
        electrumCoinRequests.add(ElectrumReq(
          coin: coin.abbr,
          servers: coin.electrum,
          swapContractAddress: coin.swapContractAddress,
          fallbackSwapContract: coin.swapContractAddress,
        ));
      } else {
        if (coin.protocolType == 'ETH') {
          ethWithTokensRequests.add(EnableEthWithTokensRequest(
            coin: coin.abbr,
            swapContractAddress: coin.swapContractAddress,
            fallbackSwapContract: coin.fallbackSwapContract,
            nodes: coin.nodes,
          ));
        } else {
          erc20Requests.add(EnableErc20Request(ticker: coin.abbr));
        }
      }
    }
    await _api.enableCoins(
      ethWithTokensRequests: ethWithTokensRequests,
      erc20Requests: erc20Requests,
      electrumCoinRequests: electrumCoinRequests,
      tendermintRequests: tendermintRequests,
      tendermintTokenRequests: tendermintTokenRequests,
      bchWithTokens: bchWithTokens,
      slpTokens: slpTokens,
    );
  }

  Future<String?> convertLegacyAddress(Coin coin, String address) async {
    final request = ConvertAddressRequest(
      coin: coin.abbr,
      from: address,
      isErc: coin.isErcType,
    );
    return await _api.convertLegacyAddress(request);
  }
}
