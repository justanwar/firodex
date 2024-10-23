import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';
import 'package:web_dex/model/withdraw_details/fee_details.dart';

// TODO: copy over the mock transaction data generator from lib

Transaction createBuyTransaction(
  double balanceChange, {
  int timeStamp = 1708646400,
}) {
  final String value = balanceChange.toString();
  return Transaction(
    blockHeight: 10000,
    coin: 'BTC',
    confirmations: 6,
    feeDetails: FeeDetails(type: 'utxo', coin: 'BTC'),
    from: ['1ABC...'],
    internalId: 'internal1',
    myBalanceChange: value,
    receivedByMe: value,
    spentByMe: '0.0',
    timestamp: timeStamp, // $50,740.50 usd
    to: ['1XYZ...'],
    totalAmount: value,
    txHash: 'hash1',
    txHex: 'hex1',
    memo: 'Buy 1 BTC',
  );
}

Transaction createSellTransaction(
  double balanceChange, {
  int timeStamp = 1714435200,
}) {
  if (!balanceChange.isNegative) {
    balanceChange = -balanceChange;
  }
  final String value = balanceChange.toString();
  return Transaction(
    blockHeight: 100200,
    coin: 'BTC',
    confirmations: 6,
    feeDetails: FeeDetails(type: 'utxo', coin: 'BTC'),
    from: ['1XYZ...'],
    internalId: 'internal3',
    myBalanceChange: value,
    receivedByMe: '0.0',
    spentByMe: balanceChange.abs().toString(),
    timestamp: timeStamp, // $60,666.60 usd
    to: ['1GHI...'],
    totalAmount: value,
    txHash: 'hash3',
    txHex: 'hex3',
    memo: 'Sell 0.5 BTC',
  );
}
