import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/transaction_history/transaction_history_event.dart';
import 'package:web_dex/bloc/transaction_history/transaction_history_repo.dart';
import 'package:web_dex/bloc/transaction_history/transaction_history_state.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/my_tx_history_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/data_from_service.dart';
import 'package:web_dex/model/text_error.dart';
import 'package:web_dex/shared/utils/utils.dart';

class TransactionHistoryBloc
    extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  TransactionHistoryBloc({
    required TransactionHistoryRepo repo,
  })  : _repo = repo,
        super(TransactionHistoryInitialState()) {
    on<TransactionHistorySubscribe>(_onSubscribe);
    on<TransactionHistoryUnsubscribe>(_onUnsubscribe);
    on<TransactionHistoryUpdated>(_onUpdated);
    on<TransactionHistoryFailure>(_onFailure);
  }

  final TransactionHistoryRepo _repo;
  Timer? _updateTransactionsTimer;
  final _updateTime = const Duration(seconds: 10);

  Future<void> _onSubscribe(
    TransactionHistorySubscribe event,
    Emitter<TransactionHistoryState> emit,
  ) async {
    if (!hasTxHistorySupport(event.coin)) {
      return;
    }
    emit(TransactionHistoryInitialState());
    await _update(event.coin);
    _stopTimers();
    _updateTransactionsTimer = Timer.periodic(_updateTime, (_) async {
      await _update(event.coin);
    });
  }

  void _onUnsubscribe(
    TransactionHistoryUnsubscribe event,
    Emitter<TransactionHistoryState> emit,
  ) {
    _stopTimers();
  }

  void _onUpdated(
    TransactionHistoryUpdated event,
    Emitter<TransactionHistoryState> emit,
  ) {
    if (event.isInProgress) {
      emit(TransactionHistoryInProgressState(transactions: event.transactions));
      return;
    }
    emit(TransactionHistoryLoadedState(transactions: event.transactions));
  }

  void _onFailure(
    TransactionHistoryFailure event,
    Emitter<TransactionHistoryState> emit,
  ) {
    emit(TransactionHistoryFailureState(error: event.error));
  }

  Future<void> _update(Coin coin) async {
    final DataFromService<TransactionHistoryResponseResult, BaseError>
        transactionsResponse = await _repo.fetch(coin);
    if (isClosed) {
      return;
    }
    final TransactionHistoryResponseResult? result = transactionsResponse.data;

    final BaseError? responseError = transactionsResponse.error;
    if (responseError != null) {
      add(TransactionHistoryFailure(error: responseError));
      return;
    } else if (result == null) {
      add(
        TransactionHistoryFailure(
          error: TextError(error: LocaleKeys.somethingWrong.tr()),
        ),
      );
      return;
    }

    final List<Transaction> transactions = List.from(result.transactions);
    transactions.sort(_sortTransactions);
    _flagTransactions(transactions, coin);

    add(
      TransactionHistoryUpdated(
        transactions: transactions,
        isInProgress: result.syncStatus.state == SyncStatusState.inProgress,
      ),
    );
  }

  @override
  Future<void> close() {
    _stopTimers();

    return super.close();
  }

  void _stopTimers() {
    _updateTransactionsTimer?.cancel();
    _updateTransactionsTimer = null;
  }
}

int _sortTransactions(Transaction tx1, Transaction tx2) {
  if (tx2.timestamp == 0) {
    return 1;
  } else if (tx1.timestamp == 0) {
    return -1;
  }
  return tx2.timestamp.compareTo(tx1.timestamp);
}

void _flagTransactions(List<Transaction> transactions, Coin coin) {
  // First response to https://trezor.io/support/a/address-poisoning-attacks,
  // need to be refactored.
  // ref: https://github.com/KomodoPlatform/komodowallet/issues/1091

  if (!coin.isErcType) return;

  for (final Transaction tx in List.from(transactions)) {
    if (double.tryParse(tx.totalAmount) == 0.0) {
      transactions.remove(tx);
    }
  }
}
