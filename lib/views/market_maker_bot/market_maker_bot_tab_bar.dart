import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/dex_tab_bar/dex_tab_bar_bloc.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/my_orders/my_order.dart';
import 'package:web_dex/model/swap.dart';
import 'package:web_dex/shared/ui/ui_tab_bar/ui_tab.dart';
import 'package:web_dex/shared/ui/ui_tab_bar/ui_tab_bar.dart';
import 'package:web_dex/views/market_maker_bot/market_maker_bot_tab_type.dart';

class MarketMakerBotTabBar extends StatelessWidget {
  const MarketMakerBotTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DexTabBarBloc, DexTabBarState>(
      builder: (context, state) {
        final DexTabBarBloc bloc = context.read<DexTabBarBloc>();
        return StreamBuilder<List<MyOrder>>(
          stream: tradingEntitiesBloc.outMyOrders,
          builder: (context, _) => StreamBuilder<List<Swap>>(
            stream: tradingEntitiesBloc.outSwaps,
            builder: (context, _) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: theme.custom.dexFormWidth),
              child: UiTabBar(
                currentTabIndex: bloc.tabIndex,
                tabs: _buidTabs(bloc),
              ),
            ),
          ),
        );
      },
    );
  }

  List<UiTab> _buidTabs(DexTabBarBloc bloc) {
    const values = MarketMakerBotTabType.values;
    return List.generate(values.length, (index) {
      final tab = values[index];
      return UiTab(
        key: Key(tab.key),
        text: tab.name(bloc),
        isSelected: bloc.state.tabIndex == index,
        onClick: () => bloc.add(TabChanged(index)),
      );
    });
  }
}
