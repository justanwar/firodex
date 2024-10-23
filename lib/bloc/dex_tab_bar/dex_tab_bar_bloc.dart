import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/auth_bloc/auth_repository.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/trading_entities_filter.dart';
import 'package:web_dex/views/market_maker_bot/tab_type_enum.dart';

part 'dex_tab_bar_event.dart';
part 'dex_tab_bar_state.dart';

class DexTabBarBloc extends Bloc<DexTabBarEvent, DexTabBarState> {
  DexTabBarBloc(super.initialState, AuthRepository authRepo) {
    on<TabChanged>(_onTabChanged);
    on<FilterChanged>(_onFilterChanged);

    _authorizationSubscription = authRepo.authMode.listen((event) {
      if (event == AuthorizeMode.noLogin) {
        add(const TabChanged(0));
      }
    });
  }

  @override
  Future<void> close() {
    _authorizationSubscription.cancel();
    return super.close();
  }

  late StreamSubscription<AuthorizeMode> _authorizationSubscription;
  int get tabIndex => state.tabIndex;

  int get ordersCount => tradingEntitiesBloc.myOrders.length;

  int get inProgressCount =>
      tradingEntitiesBloc.swaps.where((swap) => !swap.isCompleted).length;

  int get completedCount =>
      tradingEntitiesBloc.swaps.where((swap) => swap.isCompleted).length;

  FutureOr<void> _onTabChanged(TabChanged event, Emitter<DexTabBarState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  void _onFilterChanged(FilterChanged event, Emitter<DexTabBarState> emit) {
    emit(
      state.copyWith(
        filters: {
          ...state.filters,
          event.tabType: event.filter,
        },
      ),
    );
  }
}
