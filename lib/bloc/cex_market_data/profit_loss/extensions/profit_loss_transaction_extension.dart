import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';

extension ProfitLossTransactionExtension on Transaction {
  /// The total amount of the coin transferred in the transaction as a double.
  /// This is the absolute value of the [totalAmount].
  double get totalAmountAsDouble => double.parse(totalAmount).abs();

  /// The amount of the coin received in the transaction as a double.
  /// This is the [receivedByMe] as a double.
  double get amountReceived => double.parse(receivedByMe);

  /// The amount of the coin spent in the transaction as a double.
  /// This is the [spentByMe] as a double.
  double get amountSpent => double.parse(spentByMe);

  /// The net change in the coin balance as a double.
  /// This is the [myBalanceChange] as a double.
  double get balanceChange => double.parse(myBalanceChange);

  /// The timestamp of the transaction as a [DateTime] at midnight.
  DateTime get timeStampMidnight =>
      DateTime(timestampDate.year, timestampDate.month, timestampDate.day);

  /// Returns true if the transaction is a deposit. I.e. the user receives the
  /// coin and does not spend any of it. This is true if the transaction is
  /// on the receiving end of a transaction, as the sender pays transaction fees
  /// for UTXO coins and the receiver does not.
  bool get isDeposit =>
      amountReceived > 0 && amountSpent == 0 && balanceChange > 0;
}
