import 'dart:convert';

import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/fiat/base_fiat_provider.dart';
import 'package:web_dex/bloc/fiat/fiat_order_status.dart';
import 'package:web_dex/model/coin_type.dart';
import 'package:web_dex/shared/utils/utils.dart';

class BanxaFiatProvider extends BaseFiatProvider {
  final String providerId = "Banxa";
  final String apiEndpoint = "/api/v1/banxa";

  BanxaFiatProvider();

  @override
  String getProviderId() {
    return providerId;
  }

  @override
  String get providerIconPath => '$assetsPath/fiat/providers/banxa_icon.svg';

  FiatOrderStatus _parseStatusFromResponse(Map<String, dynamic> response) {
    final statusString = response['data']?['order']?['status'] as String?;

    return _parseOrderStatus(statusString ?? '');
  }

  Future _getPaymentMethods(
    String source,
    Currency target, {
    String? sourceAmount,
  }) =>
      apiRequest(
        'GET',
        apiEndpoint,
        queryParams: {
          'endpoint': '/api/payment-methods',
          'source': source,
          'target': target.symbol
        },
      );

  Future _getPricesWithPaymentMethod(
    String source,
    Currency target,
    String sourceAmount,
    Map<String, dynamic> paymentMethod,
  ) =>
      apiRequest(
        'GET',
        apiEndpoint,
        queryParams: {
          'endpoint': '/api/prices',
          'source': source,
          'target': target.symbol,
          'source_amount': sourceAmount,
          'payment_method_id': paymentMethod['id'].toString(),
        },
      );

  Future _createOrder(Map<String, dynamic> payload) =>
      apiRequest('POST', apiEndpoint,
          queryParams: {
            'endpoint': '/api/orders',
          },
          body: payload);

  Future _getOrder(String orderId) =>
      apiRequest('GET', apiEndpoint, queryParams: {
        'endpoint': '/api/orders',
        'order_id': orderId,
      });

  Future _getFiats() => apiRequest(
        'GET',
        apiEndpoint,
        queryParams: {
          'endpoint': '/api/fiats',
          'orderType': 'buy',
        },
      );

  Future _getCoins() => apiRequest(
        'GET',
        apiEndpoint,
        queryParams: {
          'endpoint': '/api/coins',
          'orderType': 'buy',
        },
      );

  FiatOrderStatus _parseOrderStatus(String status) {
    // The case statements are references to Banxa's order statuses. See the
    // docs link here for more info: https://docs.banxa.com/docs/order-status
    switch (status) {
      case 'complete':
        return FiatOrderStatus.success;

      case 'cancelled':
      case 'declined':
      case 'expired':
      case 'refunded':
        return FiatOrderStatus.failed;

      case 'extraVerification':
      case 'pendingPayment':
      case 'waitingPayment':
        return FiatOrderStatus.pending;

      case 'paymentReceived':
      case 'inProgress':
      case 'coinTransferred':
        return FiatOrderStatus.inProgress;

      default:
        throw Exception('Unknown status: $status');
    }
  }

  // These will be in BLOC:
  @override
  Stream<FiatOrderStatus> watchOrderStatus(String orderId) async* {
    FiatOrderStatus? lastStatus;

    // TODO: At the moment we're polling the API for order status. We can
    // further optimise this by listening for the status redirect page post
    // message, but adds the challenge that we add further web-only code that
    // needs to be re-implemented for mobile/desktop.
    while (true) {
      final response = await _getOrder(orderId)
          .catchError((e) => Future.error('Error fetching order: $e'));

      log('Fiat order status response:\n${jsonEncode(response)}');

      final status = _parseStatusFromResponse(response);

      final isCompleted =
          status == FiatOrderStatus.success || status == FiatOrderStatus.failed;

      if (status != lastStatus) {
        lastStatus = status;

        yield status;
      }

      if (isCompleted) break;

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  Future<List<Currency>> getFiatList() async {
    final response = await _getFiats();
    final data = response['data']['fiats'] as List<dynamic>;
    return data
        .map((item) => Currency(
              item['fiat_code'] as String,
              item['fiat_name'] as String,
              isFiat: true,
            ))
        .toList();
  }

  @override
  Future<List<Currency>> getCoinList() async {
    final response = await _getCoins();
    final data = response['data']['coins'] as List<dynamic>;

    List<Currency> currencyList = [];
    for (final item in data) {
      final coinCode = item['coin_code'] as String;
      final coinName = item['coin_name'] as String;
      final blockchains = item['blockchains'] as List<dynamic>;

      for (final blockchain in blockchains) {
        currencyList.add(
          Currency(
            coinCode,
            coinName,
            chainType: getCoinType(blockchain['code'] as String),
            isFiat: false,
          ),
        );
      }
    }

    return currencyList;
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethodsList(
    String source,
    Currency target,
    String sourceAmount,
  ) async {
    try {
      final response =
          await _getPaymentMethods(source, target, sourceAmount: sourceAmount);
      List<Map<String, dynamic>> paymentMethods =
          List<Map<String, dynamic>>.from(response['data']['payment_methods']);

      List<Future<Map<String, dynamic>>> priceFutures = [];
      for (final paymentMethod in paymentMethods) {
        final futurePrice = getPaymentMethodPrice(
          source,
          target,
          sourceAmount,
          paymentMethod,
        );
        priceFutures.add(futurePrice);
      }

      // Wait for all futures to complete
      List<Map<String, dynamic>> prices = await Future.wait(priceFutures);

      // Combine price information with payment methods
      for (int i = 0; i < paymentMethods.length; i++) {
        paymentMethods[i]['price_info'] = prices[i];
      }

      return paymentMethods;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getPaymentMethodPrice(
    String source,
    Currency target,
    String sourceAmount,
    Map<String, dynamic> paymentMethod,
  ) async {
    try {
      final response = await _getPricesWithPaymentMethod(
        source,
        target,
        sourceAmount,
        paymentMethod,
      );
      return Map<String, dynamic>.from(response['data']['prices'][0]);
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> buyCoin(
    String accountReference,
    String source,
    Currency target,
    String walletAddress,
    String paymentMethodId,
    String sourceAmount,
    String returnUrlOnSuccess,
  ) async {
    final payload = {
      'account_reference': accountReference,
      'source': source,
      'target': target.symbol,
      "wallet_address": walletAddress,
      'payment_method_id': paymentMethodId,
      'source_amount': sourceAmount,
      'return_url_on_success': returnUrlOnSuccess,
    };

    log('Fiat buy coin order payload:');
    log(jsonEncode(payload));
    final response = await _createOrder(payload);
    log('Fiat buy coin order response:');
    log(jsonEncode(response));

    return Map<String, dynamic>.from(response);
  }

  @override
  String? getCoinChainId(Currency currency) {
    switch (currency.chainType) {
      case CoinType.bep20:
        return 'BNB'; // It's BSC usually, different for this provider
      default:
        break;
    }

    return super.getCoinChainId(currency);
  }
}
