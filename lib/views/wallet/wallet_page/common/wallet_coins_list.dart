import 'package:flutter/material.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/views/wallet/wallet_page/common/coin_list_item.dart';

class WalletCoinsList extends StatelessWidget {
  const WalletCoinsList({
    Key? key,
    required this.coins,
    required this.onCoinItemTap,
  }) : super(key: key);

  final List<Coin> coins;
  final Function(Coin) onCoinItemTap;

  @override
  Widget build(BuildContext context) {
    return SliverList(
        key: const Key('wallet-page-coins-list'),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Coin coin = coins[index];
            final bool isEven = (index + 1) % 2 == 0;
            final Color backgroundColor = isEven
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onSurface;
            return CoinListItem(
              key: Key('wallet-coin-list-item-${coin.abbr.toLowerCase()}'),
              coin: coin,
              backgroundColor: backgroundColor,
              onTap: onCoinItemTap,
            );
          },
          childCount: coins.length,
        ));
  }
}
