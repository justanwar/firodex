import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc.dart';
import 'package:web_dex/bloc/auth_bloc/auth_bloc_state.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/swap.dart';
import 'package:web_dex/router/state/fiat_state.dart';
import 'package:web_dex/router/state/routing_state.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/views/common/pages/page_layout.dart';
import 'package:web_dex/views/dex/entities_list/history/history_list.dart';
import 'package:web_dex/views/dex/entities_list/in_progress/in_progress_list.dart';
import 'package:web_dex/views/dex/entity_details/trading_details.dart';
import 'package:web_dex/views/fiat/fiat_form.dart';

class FiatPage extends StatefulWidget {
  const FiatPage() : super(key: const Key('fiat-page'));

  @override
  State<StatefulWidget> createState() => _FiatPageState();
}

class _FiatPageState extends State<FiatPage> with TickerProviderStateMixin {
  int _activeTabIndex = 0;
  bool _showSwap = false;

  @override
  void initState() {
    routingState.fiatState.addListener(_onRouteChange);
    super.initState();
  }

  @override
  void dispose() {
    routingState.fiatState.removeListener(_onRouteChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) {
        if (state.mode == AuthorizeMode.noLogin) {
          setState(() {
            _activeTabIndex = 0;
          });
        }
      },
      child: _showSwap ? _buildTradingDetails() : _buildFiatPage(),
    );
  }

  Widget _buildTradingDetails() {
    return TradingDetails(
      uuid: routingState.fiatState.uuid,
    );
  }

  Widget _buildFiatPage() {
    return PageLayout(
      content: Expanded(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          margin: isMobile ? const EdgeInsets.only(top: 14) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _backgroundColor(context),
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TODO: Future feature to show fiat purchase history. Until then,
              // we'll hide the tabs since only the first one is used.
              // ConstrainedBox(
              //   constraints:
              //       BoxConstraints(maxWidth: theme.custom.dexFormWidth),
              //   child: HiddenWithoutWallet(
              //     child: FiatTabBar(
              //       currentTabIndex: _activeTabIndex,
              //       onTabClick: _setActiveTab,
              //     ),
              //   ),
              // ),
              Flexible(
                child: _TabContent(
                  activeTabIndex: _activeTabIndex,
                  onCheckoutComplete: _onCheckoutComplete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Will be used in the future for switching between tabs when we implement
  // the purchase history tab.
  // void _setActiveTab(int i) {
  //   setState(() {
  //     _activeTabIndex = i;
  //   });
  // }

  Color? _backgroundColor(BuildContext context) {
    if (isMobile) {
      final ThemeMode mode = theme.mode;
      return mode == ThemeMode.dark ? null : Theme.of(context).cardColor;
    }
    return null;
  }

  void _onRouteChange() {
    setState(() {
      _showSwap = routingState.fiatState.action == FiatAction.tradingDetails;
    });
  }

  void _onCheckoutComplete({required bool isSuccess}) {
    if (isSuccess) {
      // In the future, we will navigate to the purchase history tab when the
      // purchase is complete.
      // _setActiveTab(1);
    }
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required int activeTabIndex,
    required this.onCheckoutComplete,
    // ignore: unused_element
    super.key,
  }) : _activeTabIndex = activeTabIndex;

  // TODO: Remove this when we have a proper bloc for this page
  final Function({required bool isSuccess}) onCheckoutComplete;

  final int _activeTabIndex;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabContents = [
      FiatForm(onCheckoutComplete: onCheckoutComplete),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: InProgressList(
          filter: _fiatSwapsFilter,
          onItemClick: _onSwapItemClick,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: HistoryList(
          filter: _fiatSwapsFilter,
          onItemClick: _onSwapItemClick,
        ),
      ),
    ];

    return tabContents[_activeTabIndex];
  }

  void _onSwapItemClick(Swap swap) {
    routingState.fiatState.setDetailsAction(swap.uuid);
  }

  bool _fiatSwapsFilter(Swap swap) {
    return abbr2Ticker(swap.sellCoin) == abbr2Ticker(swap.buyCoin);
  }
}
