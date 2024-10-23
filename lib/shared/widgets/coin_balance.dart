import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/shared/widgets/coin_fiat_balance.dart';

class CoinBalance extends StatelessWidget {
  const CoinBalance({required this.coin});
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          doubleToString(coin.balance),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        CoinFiatBalance(
          coin,
          style: TextStyle(color: theme.custom.increaseColor),
        ),
      ],
    );
  }
}
