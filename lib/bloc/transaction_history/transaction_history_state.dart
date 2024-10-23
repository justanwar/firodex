import 'package:equatable/equatable.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';

abstract class TransactionHistoryState extends Equatable {}

class TransactionHistoryInitialState extends TransactionHistoryState {
  @override
  List<Object?> get props => [];
}

class TransactionHistoryInProgressState extends TransactionHistoryState {
  TransactionHistoryInProgressState({required this.transactions});
  final List<Transaction> transactions;

  @override
  List<Object?> get props => [transactions];
}

class TransactionHistoryLoadedState extends TransactionHistoryState {
  TransactionHistoryLoadedState({required this.transactions});
  final List<Transaction> transactions;

  @override
  List<Object?> get props => [transactions];
}

class TransactionHistoryFailureState extends TransactionHistoryState {
  TransactionHistoryFailureState({required this.error});
  final BaseError error;

  @override
  List<Object?> get props => [error];
}
