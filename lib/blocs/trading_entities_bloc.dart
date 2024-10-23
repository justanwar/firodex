import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rational/rational.dart';
import 'package:web_dex/bloc/auth_bloc/auth_repository.dart';
import 'package:web_dex/blocs/bloc_base.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/cancel_order/cancel_order_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_recent_swaps/my_recent_swaps_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/recover_funds_of_swap/recover_funds_of_swap_response.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/my_orders/my_order.dart';
import 'package:web_dex/model/swap.dart';
import 'package:web_dex/services/orders_service/my_orders_service.dart';
import 'package:web_dex/services/swaps_service/swaps_service.dart';

class TradingEntitiesBloc implements BlocBase {
  TradingEntitiesBloc() {
    _authModeListener = authRepo.authMode.listen((mode) => _authMode = mode);
  }

  AuthorizeMode? _authMode;
  StreamSubscription<AuthorizeMode>? _authModeListener;
  List<MyOrder> _myOrders = [];
  List<Swap> _swaps = [];
  Timer? timer;

  final StreamController<List<MyOrder>> _myOrdersController =
      StreamController<List<MyOrder>>.broadcast();
  Sink<List<MyOrder>> get _inMyOrders => _myOrdersController.sink;
  Stream<List<MyOrder>> get outMyOrders => _myOrdersController.stream;
  List<MyOrder> get myOrders => _myOrders;
  set myOrders(List<MyOrder> orderList) {
    orderList.sort((first, second) => second.createdAt - first.createdAt);
    _myOrders = orderList;
    _inMyOrders.add(_myOrders);
  }

  final StreamController<List<Swap>> _swapsController =
      StreamController<List<Swap>>.broadcast();
  Sink<List<Swap>> get _inSwaps => _swapsController.sink;
  Stream<List<Swap>> get outSwaps => _swapsController.stream;
  List<Swap> get swaps => _swaps;
  set swaps(List<Swap> swapList) {
    swapList.sort(
        (first, second) => second.myInfo.startedAt - first.myInfo.startedAt);
    _swaps = swapList;
    _inSwaps.add(_swaps);
  }

  Future<void> fetch() async {
    myOrders = await myOrdersService.getOrders() ?? [];
    swaps = await swapsService.getRecentSwaps(MyRecentSwapsRequest()) ?? [];
  }

  @override
  void dispose() {
    _authModeListener?.cancel();
  }

  bool get _shouldFetchDexUpdates {
    if (_authMode == AuthorizeMode.noLogin) return false;
    if (_authMode == AuthorizeMode.hiddenLogin) return false;
    if (currentWalletBloc.wallet?.isHW == true) return false;

    return true;
  }

  void runUpdate() {
    bool updateInProgress = false;

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_shouldFetchDexUpdates) return;
      if (updateInProgress) return;

      updateInProgress = true;
      await fetch();
      updateInProgress = false;
    });
  }

  Future<RecoverFundsOfSwapResponse?> recoverFundsOfSwap(String uuid) async {
    return swapsService.recoverFundsOfSwap(uuid);
  }

  Future<String?> cancelOrder(String uuid) async {
    final Map<String, dynamic> response =
        await mm2Api.cancelOrder(CancelOrderRequest(uuid: uuid));
    return response['error'];
  }

  bool isCoinBusy(String coin) {
    return (_swaps
                .where((swap) => !swap.isCompleted)
                .where((swap) => swap.sellCoin == coin || swap.buyCoin == coin)
                .toList()
                .length +
            _myOrders
                .where((order) => order.base == coin || order.rel == coin)
                .toList()
                .length) >
        0;
  }

  double getPriceFromAmount(Rational sellAmount, Rational buyAmount) {
    final sellDoubleAmount = sellAmount.toDouble();
    final buyDoubleAmount = buyAmount.toDouble();

    if (sellDoubleAmount == 0 || buyDoubleAmount == 0) return 0;
    return buyDoubleAmount / sellDoubleAmount;
  }

  String getTypeString(bool isTaker) =>
      isTaker ? LocaleKeys.takerOrder.tr() : LocaleKeys.makerOrder.tr();

  Swap? getSwap(String uuid) =>
      swaps.firstWhereOrNull((swap) => swap.uuid == uuid);

  double getProgressFillSwap(MyOrder order) {
    final List<Swap> swaps = (order.startedSwaps ?? [])
        .map((id) => getSwap(id))
        .whereType<Swap>()
        .toList();
    final double swapFill = swaps.fold(
        0,
        (previousValue, swap) =>
            previousValue + swap.myInfo.myAmount.toDouble());
    return swapFill / order.baseAmount.toDouble();
  }

  Future<void> cancelAllOrders() async {
    final futures = myOrders.map((o) => cancelOrder(o.uuid));
    Future.wait(futures);
  }
}
