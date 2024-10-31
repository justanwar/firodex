import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_utils.dart';
import 'package:web_dex/views/wallet/wallet_page/common/wallet_coins_list.dart';

class AllCoinsList extends StatelessWidget {
  const AllCoinsList({
    Key? key,
    required this.searchPhrase,
    required this.withBalance,
    required this.onCoinItemTap,
  }) : super(key: key);
  final String searchPhrase;
  final bool withBalance;
  final Function(Coin) onCoinItemTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Coin>>(
        initialData: coinsBloc.knownCoins,
        stream: coinsBloc.outKnownCoins,
        builder: (context, AsyncSnapshot<List<Coin>> snapshot) {
          final List<Coin> coins = snapshot.data ?? [];

          if (coins.isEmpty) {
            return const SliverToBoxAdapter(child: UiSpinner());
          }

          final displayedCoins =
              sortByPriority(filterCoinsByPhrase(coins, searchPhrase));
          return WalletCoinsList(
            coins: displayedCoins.toList(),
            onCoinItemTap: onCoinItemTap,
          );
        });
  }
}
