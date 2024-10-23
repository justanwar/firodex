import 'package:rational/rational.dart';
import 'package:web_dex/mm2/mm2_api/rpc/market_maker_bot/trade_coin_pair_config.dart';
import 'package:web_dex/model/my_orders/my_order.dart';

class TradePair {
  TradePair(this.config, this.order);

  final TradeCoinPairConfig config;
  final MyOrder? order;

  MyOrder get orderPreview => MyOrder(
        base: config.baseCoinId,
        rel: config.relCoinId,
        baseAmount: Rational.zero,
        relAmount: Rational.zero,
        cancelable: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        uuid: '',
        orderType: TradeSide.maker,
      );

  TradePair copyWith({
    TradeCoinPairConfig? config,
    MyOrder? order,
  }) {
    return TradePair(
      config ?? this.config,
      order ?? this.order,
    );
  }
}
