import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';
import 'package:web_dex/model/coin.dart';

abstract class TransactionHistoryEvent {
  const TransactionHistoryEvent();
}

class TransactionHistorySubscribe extends TransactionHistoryEvent {
  const TransactionHistorySubscribe({required this.coin});
  final Coin coin;
}

class TransactionHistoryUnsubscribe extends TransactionHistoryEvent {
  const TransactionHistoryUnsubscribe({required this.coin});
  final Coin coin;
}

class TransactionHistoryUpdated extends TransactionHistoryEvent {
  const TransactionHistoryUpdated({
    required this.transactions,
    required this.isInProgress,
  });
  final List<Transaction> transactions;
  final bool isInProgress;
}

class TransactionHistoryFailure extends TransactionHistoryEvent {
  TransactionHistoryFailure({required this.error});
  final BaseError error;
}
