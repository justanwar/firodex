import 'package:equatable/equatable.dart';
import 'package:komodo_persistence_layer/komodo_persistence_layer.dart';
import 'package:web_dex/bloc/cex_market_data/profit_loss/models/profit_loss.dart';

/// Cache for profit/loss data.
///
/// This class is used to store profit/loss data in a Hive box.
class ProfitLossCache extends Equatable
    implements ObjectWithPrimaryKey<String> {
  const ProfitLossCache({
    required this.coinId,
    required this.fiatCoinId,
    required this.lastUpdated,
    required this.profitLosses,
    required this.walletId,
  });

  /// The komodo coin abbreviation from the coins repository (e.g. BTC, KMD, etc.).
  final String coinId;

  /// The id of the stable coin that [coinId] is converted to (e.g. USDT, USD, etc.).
  /// This can be any coinId, but the intention is to use a stable coin to
  /// represent the fiat value of the coin in the profit/loss calculation.
  final String fiatCoinId;

  /// The wallet ID associated with the profit/loss data.
  final String walletId;

  /// The timestamp of the last update in seconds since epoch. (e.g. [DateTime.now().millisecondsSinceEpoch ~/ 1000])
  final DateTime lastUpdated;

  /// The list of [ProfitLoss] data.
  final List<ProfitLoss> profitLosses;

  @override
  get primaryKey => getPrimaryKey(coinId, fiatCoinId, walletId);

  static String getPrimaryKey(
    String coinId,
    String fiatCurrency,
    String walletId,
  ) =>
      '$coinId-$fiatCurrency-$walletId';

  @override
  List<Object?> get props => [coinId, fiatCoinId, lastUpdated, profitLosses];
}
