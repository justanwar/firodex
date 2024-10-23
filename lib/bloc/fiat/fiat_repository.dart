import 'package:web_dex/bloc/coins_bloc/coins_repo.dart';
import 'package:web_dex/bloc/fiat/banxa_fiat_provider.dart';
import 'package:web_dex/bloc/fiat/base_fiat_provider.dart';
import 'package:web_dex/bloc/fiat/fiat_order_status.dart';
import 'package:web_dex/bloc/fiat/ramp/ramp_fiat_provider.dart';
import 'package:web_dex/shared/utils/utils.dart';

final fiatRepository =
    FiatRepository([BanxaFiatProvider(), RampFiatProvider()]);

class FiatRepository {
  final List<BaseFiatProvider> fiatProviders;
  FiatRepository(this.fiatProviders);

  String? _paymentMethodFiat;
  Currency? _paymentMethodsCoin;
  List<Map<String, dynamic>>? _paymentMethodsList;

  BaseFiatProvider? _getPaymentMethodProvider(
    Map<String, dynamic> paymentMethod,
  ) {
    return _getProvider(paymentMethod['provider_id'].toString());
  }

  BaseFiatProvider? _getProvider(
    String providerId,
  ) {
    for (final provider in fiatProviders) {
      if (provider.getProviderId() == providerId) {
        return provider;
      }
    }
    return null;
  }

  Stream<FiatOrderStatus> watchOrderStatus(
    Map<String, dynamic> paymentMethod,
    String orderId,
  ) async* {
    final provider = _getPaymentMethodProvider(paymentMethod);
    if (provider == null) yield* Stream.error('Provider not found');

    yield* provider!.watchOrderStatus(orderId);
  }

  Future<List<Currency>> _getListFromProviders(
      Future<List<Currency>> Function(BaseFiatProvider) getList,
      bool isCoin) async {
    final futures = fiatProviders.map(getList);
    final results = await Future.wait(futures);

    final currencyMap = <String, Currency>{};

    Set<String>? knownCoinAbbreviations;

    if (isCoin) {
      final knownCoins = await coinsRepo.getKnownCoins();
      knownCoinAbbreviations = knownCoins.map((coin) => coin.abbr).toSet();
    }

    for (final currencyList in results) {
      for (final currency in currencyList) {
        // Skip unsupported chains and coins
        if (isCoin &&
            (currency.chainType == null ||
                !knownCoinAbbreviations!.contains(currency.getAbbr()))) {
          continue;
        }

        // Fill the map and replace missing image ones
        currencyMap.putIfAbsent(currency.getAbbr(), () => currency);
      }
    }

    return currencyMap.values.toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));
  }

  Future<List<Currency>> getFiatList() async {
    return (await _getListFromProviders(
        (provider) => provider.getFiatList(), false))
      ..sort((a, b) => currencySorter(a.getAbbr(), b.getAbbr()));
  }

  // Order fiat list by common currencies first (fixed order), then the
  // remaining are sorted alphabetically
  int currencySorter(String a, String b) {
    const List<String> commonCurrencies = ['USD', 'EUR', 'GBP'];

    if (commonCurrencies.contains(a) && commonCurrencies.contains(b)) {
      return commonCurrencies.indexOf(a).compareTo(commonCurrencies.indexOf(b));
    } else if (commonCurrencies.contains(a)) {
      return -1;
    } else if (commonCurrencies.contains(b)) {
      return 1;
    } else {
      return a.compareTo(b);
    }
  }

  Future<List<Currency>> getCoinList() async {
    return _getListFromProviders((provider) => provider.getCoinList(), true);
  }

  String? _calculateCoinAmount(String fiatAmount, String spotPriceIncludingFee,
      {int decimalPoints = 8}) {
    if (fiatAmount.isEmpty || spotPriceIncludingFee.isEmpty) {
      return null;
    }

    try {
      final fiat = double.parse(fiatAmount);
      final spotPrice = double.parse(spotPriceIncludingFee);
      if (spotPrice == 0) return null;

      final coinAmount = fiat / spotPrice;
      return coinAmount.toStringAsFixed(decimalPoints);
    } catch (e) {
      return null;
    }
  }

  String _calculateSpotPriceIncludingFee(Map<String, dynamic> paymentMethod) {
    // Use the previous coin and fiat amounts to estimate the spot price
    // including fee.
    final coinAmount =
        double.parse(paymentMethod['price_info']['coin_amount'] as String);
    final fiatAmount =
        double.parse(paymentMethod['price_info']['fiat_amount'] as String);
    final spotPriceIncludingFee = fiatAmount / coinAmount;
    return spotPriceIncludingFee.toString();
  }

  int? _getDecimalPoints(String amount) {
    final decimalPointIndex = amount.indexOf('.');
    if (decimalPointIndex == -1) {
      return null;
    }
    return amount.substring(decimalPointIndex + 1).length;
  }

  List<Map<String, dynamic>>? _getPaymentListEstimate(
    List<Map<String, dynamic>> paymentMethodsList,
    String sourceAmount,
    Currency target,
    String source,
  ) {
    if (target != _paymentMethodsCoin || source != _paymentMethodFiat) {
      _paymentMethodsCoin = null;
      _paymentMethodFiat = null;
      _paymentMethodsList = null;
      return null;
    }

    try {
      return paymentMethodsList.map((method) {
        String? spotPriceIncludingFee;
        spotPriceIncludingFee = _calculateSpotPriceIncludingFee(method);
        int decimalAmount =
            _getDecimalPoints(method['price_info']['coin_amount']) ?? 8;

        final coinAmount = _calculateCoinAmount(
          sourceAmount,
          spotPriceIncludingFee,
          decimalPoints: decimalAmount,
        );

        return {
          ...method,
          "price_info": {
            ...method['price_info'],
            "coin_amount": coinAmount,
            "fiat_amount": sourceAmount,
          }.map((key, value) => MapEntry(key as String, value)),
        };
      }).toList();
    } catch (e) {
      log('Fiat payment list estimation failed',
          isError: true, trace: StackTrace.current, path: 'fiat_repository');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getPaymentMethodsList(
    String source,
    Currency target,
    String sourceAmount,
  ) async* {
    if (_paymentMethodsList != null) {
      // Try to estimate the payment list based on the cached one
      // This is to display temporary values while the new list is being fetched
      // This is not a perfect solution
      _paymentMethodsList = _getPaymentListEstimate(
          _paymentMethodsList!, sourceAmount, target, source);
      if (_paymentMethodsList != null) {
        _paymentMethodsCoin = target;
        _paymentMethodFiat = source;
        yield _paymentMethodsList!;
      }
    }

    final futures = fiatProviders.map((provider) async {
      final paymentMethods =
          await provider.getPaymentMethodsList(source, target, sourceAmount);
      return paymentMethods
          .map((method) => {
                ...method,
                'provider_id': provider.getProviderId(),
                'provider_icon_asset_path': provider.providerIconPath,
              })
          .toList();
    });

    final results = await Future.wait(futures);
    _paymentMethodsList = results.expand((x) => x).toList();
    _paymentMethodsList = _addRelativePercentField(_paymentMethodsList!);

    _paymentMethodsCoin = target;
    _paymentMethodFiat = source;
    yield _paymentMethodsList!;
  }

  Future<Map<String, dynamic>> getPaymentMethodPrice(
    String source,
    Currency target,
    String sourceAmount,
    Map<String, dynamic> buyPaymentMethod,
  ) async {
    final provider = _getPaymentMethodProvider(buyPaymentMethod);
    if (provider == null) return Future.error("Provider not found");

    return await provider.getPaymentMethodPrice(
      source,
      target,
      sourceAmount,
      buyPaymentMethod,
    );
  }

  Future<Map<String, dynamic>> buyCoin(
    String accountReference,
    String source,
    Currency target,
    String walletAddress,
    Map<String, dynamic> paymentMethod,
    String sourceAmount,
    String returnUrlOnSuccess,
  ) async {
    final provider = _getPaymentMethodProvider(paymentMethod);
    if (provider == null) return Future.error("Provider not found");

    return await provider.buyCoin(
      accountReference,
      source,
      target,
      walletAddress,
      paymentMethod['id'].toString(),
      sourceAmount,
      returnUrlOnSuccess,
    );
  }

  List<Map<String, dynamic>> _addRelativePercentField(
      List<Map<String, dynamic>> paymentMethodsList) {
    // Add a relative percent value to each payment method
    // based on the payment method with the highest `coin_amount`
    try {
      final coinAmounts = _paymentMethodsList!
          .map((method) => double.parse(method['price_info']['coin_amount']))
          .toList();
      final maxCoinAmount = coinAmounts.reduce((a, b) => a > b ? a : b);
      return _paymentMethodsList!.map((method) {
        final coinAmount = double.parse(method['price_info']['coin_amount']);
        if (coinAmount == 0) {
          return method;
        }
        if (coinAmount == maxCoinAmount) {
          return {
            ...method,
            'relative_percent': null,
          };
        }

        final relativeValue =
            (coinAmount - maxCoinAmount) / (maxCoinAmount).abs();

        return {
          ...method,
          'relative_percent': relativeValue, //0 to -1
        };
      }).toList()
        ..sort((a, b) {
          if (a['relative_percent'] == null) return -1;
          if (b['relative_percent'] == null) return 1;
          return (b['relative_percent'] as double)
              .compareTo(a['relative_percent'] as double);
        });
    } catch (e) {
      log('Failed to add relative percent field to payment methods list',
          isError: true, trace: StackTrace.current, path: 'fiat_repository');
      return paymentMethodsList;
    }
  }
}
