import 'package:web_dex/bloc/market_maker_bot/market_maker_order_list/trade_pair.dart';
import 'package:web_dex/bloc/settings/settings_repository.dart';
import 'package:web_dex/mm2/mm2_api/rpc/market_maker_bot/trade_coin_pair_config.dart';
import 'package:web_dex/model/my_orders/my_order.dart';
import 'package:web_dex/services/orders_service/my_orders_service.dart';

class MarketMakerBotOrderListRepository {
  final MyOrdersService _ordersService;
  final SettingsRepository _settingsRepository;

  const MarketMakerBotOrderListRepository(
    this._ordersService,
    this._settingsRepository,
  );

  Future<void> cancelOrders(List<TradeCoinPairConfig> tradePairs) async {
    final orders = await _ordersService.getOrders();
    final ordersToCancel = orders
        ?.where(
          (order) =>
              tradePairs.any(
                (tradePair) =>
                    order.base == tradePair.baseCoinId &&
                    order.rel == tradePair.relCoinId,
              ) &&
              order.orderType == TradeSide.maker,
        )
        .toList();

    if (ordersToCancel?.isEmpty == true) {
      return;
    }

    for (final order in ordersToCancel!) {
      await _ordersService.cancelOrder(order.uuid);
    }
  }

  Future<List<TradePair>> getTradePairs() async {
    final settings = await _settingsRepository.loadSettings();
    final configs = settings.marketMakerBotSettings.tradeCoinPairConfigs;
    final makerOrders = (await _ordersService.getOrders())
        ?.where((order) => order.orderType == TradeSide.maker);

    final tradePairs = configs
        .map(
          (e) => TradePair(
            e,
            makerOrders
                ?.where(
                  (order) =>
                      order.base == e.baseCoinId && order.rel == e.relCoinId,
                )
                .firstOrNull,
          ),
        )
        .toList();

    return tradePairs;
  }
}
