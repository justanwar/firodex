import 'package:web_dex/bloc/cex_market_data/profit_loss/models/fiat_value.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';

class PriceStampedTransaction extends Transaction {
  final FiatValue fiatValue;

  PriceStampedTransaction({
    required Transaction transaction,
    required this.fiatValue,
  }) : super(
          blockHeight: transaction.blockHeight,
          coin: transaction.coin,
          confirmations: transaction.confirmations,
          feeDetails: transaction.feeDetails,
          from: transaction.from,
          internalId: transaction.internalId,
          myBalanceChange: transaction.myBalanceChange,
          receivedByMe: transaction.receivedByMe,
          spentByMe: transaction.spentByMe,
          timestamp: transaction.timestamp,
          to: transaction.to,
          totalAmount: transaction.totalAmount,
          txHash: transaction.txHash,
          txHex: transaction.txHex,
          memo: transaction.memo,
        );
}

class UsdPriceStampedTransaction extends PriceStampedTransaction {
  double get priceUsd => fiatValue.value;
  double get totalAmountUsd =>
      (double.parse(totalAmount) * fiatValue.value).abs();
  double get balanceChangeUsd =>
      double.parse(myBalanceChange) * fiatValue.value;

  UsdPriceStampedTransaction(Transaction transaction, double priceUsd)
      : super(
          transaction: transaction,
          fiatValue: FiatValue.usd(priceUsd),
        );
}
