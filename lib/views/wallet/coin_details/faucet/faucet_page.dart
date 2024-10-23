import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/views/wallet/coin_details/faucet/faucet_view.dart';

import 'cubit/faucet_cubit.dart';

class FaucetPage extends StatelessWidget {
  const FaucetPage({
    Key? key,
    required this.coinAbbr,
    required this.onBackButtonPressed,
    required this.coinAddress,
  }) : super(key: key);

  final String coinAbbr;
  final String? coinAddress;
  final VoidCallback onBackButtonPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FaucetCubit(coinAbbr: coinAbbr, coinAddress: coinAddress),
      child: FaucetView(
        onBackButtonPressed: onBackButtonPressed,
      ),
    );
  }
}
