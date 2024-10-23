part of 'dex_tab_bar_bloc.dart';

class DexTabBarState extends Equatable {
  const DexTabBarState({required this.tabIndex, this.filters = const {}});
  factory DexTabBarState.initial() => const DexTabBarState(tabIndex: 0);

  final int tabIndex;
  final Map<TabTypeEnum, TradingEntitiesFilter?> filters;

  @override
  List<Object?> get props => [tabIndex, filters];

  DexTabBarState copyWith({
    int? tabIndex,
    Map<TabTypeEnum, TradingEntitiesFilter?>? filters,
  }) {
    return DexTabBarState(
      tabIndex: tabIndex ?? this.tabIndex,
      filters: filters ?? this.filters,
    );
  }
}
