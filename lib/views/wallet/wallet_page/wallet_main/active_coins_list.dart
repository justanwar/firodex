import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_utils.dart';
import 'package:web_dex/views/wallet/wallet_page/common/wallet_coins_list.dart';

class ActiveCoinsList extends StatelessWidget {
  const ActiveCoinsList({
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
    return StreamBuilder<bool>(
        initialData: coinsBloc.loginActivationFinished,
        stream: coinsBloc.outLoginActivationFinished,
        builder: (context, AsyncSnapshot<bool> walletCoinsEnabledSnapshot) {
          return StreamBuilder<Iterable<Coin>>(
            initialData: coinsBloc.walletCoinsMap.values,
            stream: coinsBloc.outWalletCoins,
            builder: (context, AsyncSnapshot<Iterable<Coin>> snapshot) {
              final List<Coin> coins = List.from(snapshot.data ?? <Coin>[]);
              final Iterable<Coin> displayedCoins = _getDisplayedCoins(coins);

              if (displayedCoins.isEmpty &&
                  (searchPhrase.isNotEmpty || withBalance)) {
                return SliverToBoxAdapter(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child:
                        SelectableText(LocaleKeys.walletPageNoSuchAsset.tr()),
                  ),
                );
              }

              final sorted = sortFiatBalance(displayedCoins.toList());

              return WalletCoinsList(
                coins: sorted,
                onCoinItemTap: onCoinItemTap,
              );
            },
          );
        });
  }

  Iterable<Coin> _getDisplayedCoins(Iterable<Coin> coins) =>
      filterCoinsByPhrase(coins, searchPhrase).where((Coin coin) {
        if (withBalance) {
          return coin.balance > 0;
        }
        return true;
      }).toList();
}
