import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart' show Bloc, Emitter;
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/blocs/coins_bloc.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_type.dart';
import 'package:web_dex/model/coin_utils.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/router/state/wallet_state.dart';

import 'coins_manager_event.dart';
import 'coins_manager_state.dart';

class CoinsManagerBloc extends Bloc<CoinsManagerEvent, CoinsManagerState> {
  CoinsManagerBloc({
    required CoinsBloc coinsRepo,
    required CoinsManagerAction action,
  })  : _coinsRepo = coinsRepo,
        super(
          CoinsManagerState.initial(
            action: action,
            coins: _getOriginalCoinList(coinsRepo, action),
          ),
        ) {
    on<CoinsManagerCoinsUpdate>(_onCoinsUpdate);
    on<CoinsManagerCoinTypeSelect>(_onCoinTypeSelect);
    on<CoinsManagerCoinsSwitch>(_onCoinsSwitch);
    on<CoinsManagerCoinSelect>(_onCoinSelect);
    on<CoinsManagerSelectAllTap>(_onSelectAll);
    on<CoinsManagerSelectedTypesReset>(_onSelectedTypesReset);
    on<CoinsManagerSearchUpdate>(_onSearchUpdate);

    _enabledCoinsListener = _coinsRepo.outWalletCoins
        .listen((_) => add(const CoinsManagerCoinsUpdate()));
  }
  final CoinsBloc _coinsRepo;
  late StreamSubscription<List<Coin>> _enabledCoinsListener;

  @override
  Future<void> close() {
    _enabledCoinsListener.cancel();
    return super.close();
  }

  List<Coin> mergeCoinLists(List<Coin> originalList, List<Coin> newList) {
    Map<String, Coin> coinMap = {};

    for (Coin coin in originalList) {
      coinMap[coin.abbr] = coin;
    }

    for (Coin coin in newList) {
      coinMap[coin.abbr] = coin;
    }

    final list = coinMap.values.toList();
    list.sort((a, b) => a.abbr.compareTo(b.abbr));

    return list;
  }

  void _onCoinsUpdate(
    CoinsManagerCoinsUpdate event,
    Emitter<CoinsManagerState> emit,
  ) {
    final List<FilterFunction> filters = [];

    List<Coin> list = mergeCoinLists(
        _getOriginalCoinList(_coinsRepo, state.action), state.coins);

    if (state.searchPhrase.isNotEmpty) {
      filters.add(_filterByPhrase);
    }
    if (state.selectedCoinTypes.isNotEmpty) {
      filters.add(_filterByType);
    }

    for (var filter in filters) {
      list = filter(list);
    }

    emit(state.copyWith(coins: list));
  }

  void _onCoinTypeSelect(
    CoinsManagerCoinTypeSelect event,
    Emitter<CoinsManagerState> emit,
  ) {
    final List<CoinType> newTypes = state.selectedCoinTypes.contains(event.type)
        ? state.selectedCoinTypes.where((type) => type != event.type).toList()
        : [...state.selectedCoinTypes, event.type];

    emit(state.copyWith(selectedCoinTypes: newTypes));

    add(const CoinsManagerCoinsUpdate());
  }

  Future<void> _onCoinsSwitch(
    CoinsManagerCoinsSwitch event,
    Emitter<CoinsManagerState> emit,
  ) async {
    final List<Coin> selectedCoins = [...state.selectedCoins];
    emit(state.copyWith(isSwitching: true));

    final Future<void> switchingFuture = state.action == CoinsManagerAction.add
        ? _coinsRepo.activateCoins(selectedCoins)
        : _coinsRepo.deactivateCoins(selectedCoins);

    emit(state.copyWith(selectedCoins: [], isSwitching: false));
    await switchingFuture;
  }

  void _onCoinSelect(
    CoinsManagerCoinSelect event,
    Emitter<CoinsManagerState> emit,
  ) {
    final coin = event.coin;
    final List<Coin> selectedCoins = List.from(state.selectedCoins);
    if (selectedCoins.contains(coin)) {
      selectedCoins.remove(coin);

      if (state.action == CoinsManagerAction.add) {
        _coinsRepo.deactivateCoins([event.coin]);
      } else {
        _coinsRepo.activateCoins([event.coin]);
      }
    } else {
      selectedCoins.add(coin);

      if (state.action == CoinsManagerAction.add) {
        _coinsRepo.activateCoins([event.coin]);
      } else {
        _coinsRepo.deactivateCoins([event.coin]);
      }
    }
    emit(state.copyWith(selectedCoins: selectedCoins));
  }

  FutureOr<void> _onSelectAll(
    CoinsManagerSelectAllTap event,
    Emitter<CoinsManagerState> emit,
  ) {
    final selectedCoins =
        state.isSelectedAllCoinsEnabled ? <Coin>[] : state.coins;
    emit(state.copyWith(selectedCoins: selectedCoins));
  }

  FutureOr<void> _onSelectedTypesReset(
    CoinsManagerSelectedTypesReset event,
    Emitter<CoinsManagerState> emit,
  ) {
    emit(state.copyWith(selectedCoinTypes: []));
    add(const CoinsManagerCoinsUpdate());
  }

  FutureOr<void> _onSearchUpdate(
    CoinsManagerSearchUpdate event,
    Emitter<CoinsManagerState> emit,
  ) {
    emit(state.copyWith(searchPhrase: event.text));
    add(const CoinsManagerCoinsUpdate());
  }

  List<Coin> _filterByPhrase(List<Coin> coins) {
    final String filter = state.searchPhrase.toLowerCase();
    final List<Coin> filtered = filter.isEmpty
        ? coins
        : coins
            .where(
              (Coin coin) =>
                  compareCoinByPhrase(coin, filter) ||
                  state.selectedCoins.indexWhere(
                        (selectedCoin) => selectedCoin.abbr == coin.abbr,
                      ) !=
                      -1,
            )
            .toList();

    filtered
        .sort((a, b) => a.abbr.toLowerCase().compareTo(b.abbr.toLowerCase()));
    return filtered;
  }

  List<Coin> _filterByType(List<Coin> coins) {
    return coins
        .where(
          (coin) =>
              state.selectedCoinTypes.contains(coin.type) ||
              state.selectedCoins.indexWhere(
                    (selectedCoin) => selectedCoin.abbr == coin.abbr,
                  ) !=
                  -1,
        )
        .toList();
  }
}

List<Coin> _getOriginalCoinList(
  CoinsBloc coinsRepo,
  CoinsManagerAction action,
) {
  final WalletType? walletType = currentWalletBloc.wallet?.config.type;
  if (walletType == null) return [];

  switch (action) {
    case CoinsManagerAction.add:
      return _getDeactivatedCoins(coinsRepo, walletType);
    case CoinsManagerAction.remove:
      return _getActivatedCoins(coinsRepo);
    case CoinsManagerAction.none:
      return [];
  }
}

List<Coin> _getActivatedCoins(CoinsBloc coinsRepo) {
  return coinsRepo.walletCoins.where((coin) => !coin.isActivating).toList();
}

List<Coin> _getDeactivatedCoins(CoinsBloc coinsRepo, WalletType walletType) {
  final Map<String, Coin> disabledCoinsMap = Map.from(coinsRepo.knownCoinsMap)
    ..removeWhere(
      (key, coin) =>
          coinsRepo.walletCoinsMap.containsKey(key) || coin.isActivating,
    );

  switch (walletType) {
    case WalletType.iguana:
      return disabledCoinsMap.values.toList();
    case WalletType.trezor:
      return (disabledCoinsMap
            ..removeWhere((_, coin) => !coin.hasTrezorSupport))
          .values
          .toList();
    case WalletType.metamask:
    case WalletType.keplr:
      return [];
  }
}

typedef FilterFunction = List<Coin> Function(List<Coin>);
