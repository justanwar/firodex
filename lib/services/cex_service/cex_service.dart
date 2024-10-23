import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/cex_price.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/constants.dart';
import 'package:web_dex/shared/utils/utils.dart';

class CexService {
  CexService() {
    updatePrices();
    _pricesTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      updatePrices();
    });
  }

  late Timer _pricesTimer;
  final StreamController<Map<String, CexPrice>> _pricesController =
      StreamController<Map<String, CexPrice>>.broadcast();
  Stream<Map<String, CexPrice>> get pricesStream => _pricesController.stream;

  Future<void> updatePrices() async {
    final prices = await fetchCurrentPrices();
    if (prices == null) return;

    _pricesController.sink.add(prices);
  }

  Future<Map<String, CexPrice>?> fetchCurrentPrices() async {
    final Map<String, CexPrice>? prices =
        await _updateFromMain() ?? await _updateFromFallback();

    return prices;
  }

  Future<CexPrice?> fetchPrice(String ticker) async {
    final Map<String, CexPrice>? prices = await fetchCurrentPrices();
    if (prices == null || !prices.containsKey(ticker)) return null;

    return prices[ticker]!;
  }

  void dispose() {
    _pricesTimer.cancel();
    _pricesController.close();
  }

  Future<Map<String, CexPrice>?> _updateFromMain() async {
    http.Response res;
    String body;
    try {
      res = await http.get(pricesUrlV3);
      body = res.body;
    } catch (e, s) {
      log(
        'Error updating price from main: ${e.toString()}',
        path: 'cex_services => _updateFromMain => http.get',
        trace: s,
        isError: true,
      );
      return null;
    }

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(body);
    } catch (e, s) {
      log(
        'Error parsing of update price from main response: ${e.toString()}',
        path: 'cex_services => _updateFromMain => jsonDecode',
        trace: s,
        isError: true,
      );
    }

    if (json == null) return null;
    final Map<String, CexPrice> prices = {};
    json.forEach((String priceTicker, dynamic pricesData) {
      prices[priceTicker] = CexPrice(
        ticker: priceTicker,
        price: double.tryParse(pricesData['last_price'] ?? '') ?? 0,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          pricesData['last_updated_timestamp'] * 1000,
        ),
        priceProvider: cexDataProvider(pricesData['price_provider']),
        change24h: double.tryParse(pricesData['change_24h'] ?? ''),
        changeProvider: cexDataProvider(pricesData['change_24h_provider']),
        volume24h: double.tryParse(pricesData['volume24h'] ?? ''),
        volumeProvider: cexDataProvider(pricesData['volume_provider']),
      );
    });
    return prices;
  }

  Future<Map<String, CexPrice>?> _updateFromFallback() async {
    final List<String> ids = coinsBloc.walletCoinsMap.values
        .map((c) => c.coingeckoId ?? '')
        .toList();
    ids.removeWhere((id) => id.isEmpty);
    final Uri fallbackUri = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids='
      '${ids.join(',')}&vs_currencies=usd',
    );

    http.Response res;
    String body;
    try {
      res = await http.get(fallbackUri);
      body = res.body;
    } catch (e, s) {
      log(
        'Error updating price from fallback: ${e.toString()}',
        path: 'cex_services => _updateFromFallback => http.get',
        trace: s,
        isError: true,
      );
      return null;
    }

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(body);
    } catch (e, s) {
      log(
        'Error parsing of update price from fallback response: ${e.toString()}',
        path: 'cex_services => _updateFromFallback => jsonDecode',
        trace: s,
        isError: true,
      );
    }

    if (json == null) return null;
    Map<String, CexPrice> prices = {};
    json.forEach((String coingeckoId, dynamic pricesData) {
      if (coingeckoId == 'test-coin') return;

      // Coins with the same coingeckoId supposedly have same usd price
      // (e.g. KMD == KMD-BEP20)
      final Iterable<Coin> samePriceCoins =
          coinsBloc.knownCoins.where((coin) => coin.coingeckoId == coingeckoId);

      for (Coin coin in samePriceCoins) {
        prices[coin.abbr] = CexPrice(
          ticker: coin.abbr,
          price: double.parse(pricesData['usd'].toString()),
        );
      }
    });

    return prices;
  }
}
