import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:http/http.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/my_tx_history_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/my_tx_history_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/my_tx_history_v2_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_type.dart';
import 'package:web_dex/model/data_from_service.dart';
import 'package:web_dex/model/text_error.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/shared/utils/utils.dart';

class TransactionHistoryRepo {
  TransactionHistoryRepo({required Mm2Api api, required Client client})
      : _api = api,
        _client = client;
  final Mm2Api _api;
  final Client _client;

  Future<DataFromService<TransactionHistoryResponseResult, BaseError>> fetch(
      Coin coin) async {
    if (_checkV2RequestSupport(coin)) {
      return await fetchTransactionHistoryV2(MyTxHistoryV2Request(
        coin: coin.abbr,
        type: coin.enabledType ?? WalletType.iguana,
      ));
    }
    return coin.isErcType
        ? await fetchErcTransactionHistory(coin)
        : await fetchTransactionHistory(
            MyTxHistoryRequest(
              coin: coin.abbr,
              max: true,
            ),
          );
  }

  Future<List<Transaction>> fetchTransactions(Coin coin) async {
    final historyResponse = await fetch(coin);
    final TransactionHistoryResponseResult? result = historyResponse.data;

    final BaseError? responseError = historyResponse.error;
    // TODO: add custom exceptions here?
    if (responseError != null) {
      throw TransactionFetchException('Transaction fetch error: ${responseError.message}');
    } else if (result == null) {
      throw TransactionFetchException('Transaction fetch result is null');
    }

    return result.transactions;
  }

  /// Fetches transactions for the provided [coin] where the transaction
  /// timestamp is not 0 (transaction is completed and/or confirmed).
  Future<List<Transaction>> fetchCompletedTransactions(Coin coin) async {
    final List<Transaction> transactions = await fetchTransactions(coin)
      ..sort(
        (a, b) => a.timestamp.compareTo(b.timestamp),
      );
    transactions.removeWhere((transaction) => transaction.timestamp <= 0);
    return transactions;
  }

  Future<DataFromService<TransactionHistoryResponseResult, BaseError>>
      fetchTransactionHistoryV2(MyTxHistoryV2Request request) async {
    final Map<String, dynamic>? response =
        await _api.getTransactionsHistoryV2(request);
    if (response == null) {
      return DataFromService(
        data: null,
        error: TextError(error: LocaleKeys.somethingWrong.tr()),
      );
    }

    if (response['error'] != null) {
      log(response['error'],
          path: 'transaction_history_service => fetchTransactionHistoryV2',
          isError: true);
      return DataFromService(
        data: null,
        error: TextError(error: response['error']),
      );
    }

    final MyTxHistoryResponse transactionHistory =
        MyTxHistoryResponse.fromJson(response);

    return DataFromService<TransactionHistoryResponseResult, BaseError>(
      data: transactionHistory.result,
    );
  }

  Future<DataFromService<TransactionHistoryResponseResult, BaseError>>
      fetchTransactionHistory(MyTxHistoryRequest request) async {
    final Map<String, dynamic>? response =
        await _api.getTransactionsHistory(request);
    if (response == null) {
      return DataFromService(
        data: null,
        error: TextError(error: LocaleKeys.somethingWrong.tr()),
      );
    }

    if (response['error'] != null) {
      log(response['error'],
          path: 'transaction_history_service => fetchTransactionHistory',
          isError: true);
      return DataFromService(
        data: null,
        error: TextError(error: response['error']),
      );
    }

    final MyTxHistoryResponse transactionHistory =
        MyTxHistoryResponse.fromJson(response);

    return DataFromService<TransactionHistoryResponseResult, BaseError>(
      data: transactionHistory.result,
    );
  }

  Future<DataFromService<TransactionHistoryResponseResult, BaseError>>
      fetchErcTransactionHistory(Coin coin) async {
    final String? url = getErcTransactionHistoryUrl(coin);
    if (url == null) {
      return DataFromService(
        data: null,
        error: TextError(
          error: LocaleKeys.txHistoryFetchError.tr(args: [coin.typeName]),
        ),
      );
    }

    try {
      final Response response = await _client.get(Uri.parse(url));
      final String body = response.body;
      final String result =
          body.isNotEmpty ? body : '{"result": {"transactions": []}}';
      final MyTxHistoryResponse transactionHistory =
          MyTxHistoryResponse.fromJson(json.decode(result));

      return DataFromService(
          data: _fixTestCoinsNaming(transactionHistory.result, coin),
          error: null);
    } catch (e, s) {
      final String errorString = e.toString();
      log(errorString,
          path: 'transaction_history_service => fetchErcTransactionHistory',
          trace: s,
          isError: true);
      return DataFromService(
        data: null,
        error: TextError(
          error: errorString,
        ),
      );
    }
  }

  TransactionHistoryResponseResult _fixTestCoinsNaming(
    TransactionHistoryResponseResult result,
    Coin originalCoin,
  ) {
    if (!originalCoin.isTestCoin) return result;

    final String? parentCoin = originalCoin.protocolData?.platform;
    final String feeCoin = parentCoin ?? originalCoin.abbr;

    for (Transaction tx in result.transactions) {
      tx.coin = originalCoin.abbr;
      tx.feeDetails.coin = feeCoin;
    }

    return result;
  }

  bool _checkV2RequestSupport(Coin coin) =>
      coin.enabledType == WalletType.trezor ||
      coin.protocolType == 'BCH' ||
      coin.type == CoinType.slp ||
      coin.type == CoinType.iris ||
      coin.type == CoinType.cosmos;
}

class TransactionFetchException implements Exception {
  TransactionFetchException(this.message);
  final String message;
}
