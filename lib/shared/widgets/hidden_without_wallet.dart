import 'package:flutter/material.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/wallet.dart';

class HiddenWithoutWallet extends StatelessWidget {
  const HiddenWithoutWallet(
      {Key? key, required this.child, this.isHiddenForHw = false})
      : super(key: key);
  final Widget child;
  final bool isHiddenForHw;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Wallet?>(
        initialData: currentWalletBloc.wallet,
        stream: currentWalletBloc.outWallet,
        builder: (BuildContext context,
            AsyncSnapshot<Wallet?> currentWalletSnapshot) {
          final Wallet? currentWallet = currentWalletSnapshot.data;
          if (currentWallet == null) {
            return const SizedBox.shrink();
          }

          if (isHiddenForHw && currentWallet.isHW) {
            return const SizedBox.shrink();
          }

          return child;
        });
  }
}
