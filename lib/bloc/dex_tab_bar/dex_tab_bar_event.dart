part of 'dex_tab_bar_bloc.dart';

abstract class DexTabBarEvent extends Equatable {
  const DexTabBarEvent();

  @override
  List<Object?> get props => [];
}

class TabChanged extends DexTabBarEvent {
  const TabChanged(this.tabIndex);
  final int tabIndex;
  @override
  List<Object> get props => [tabIndex];
}

class FilterChanged extends DexTabBarEvent {
  const FilterChanged({required this.tabType, required this.filter});

  final TabTypeEnum tabType;
  final TradingEntitiesFilter? filter;

  @override
  List<Object?> get props => [tabType, filter];
}
