import 'package:flutter/material.dart';
import 'package:rational/rational.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/widgets/coin_item/coin_item.dart';

class TradeAmountDesktop extends StatelessWidget {
  const TradeAmountDesktop({
    Key? key,
    required this.coinAbbr,
    required this.amount,
  }) : super(key: key);
  final String coinAbbr;
  final Rational? amount;

  @override
  Widget build(BuildContext context) {
    final Coin? coin = coinsBloc.getCoin(coinAbbr);
    if (coin == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: CoinItem(coin: coin, amount: amount?.toDouble()),
    );
  }
}
