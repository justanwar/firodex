import 'package:flutter/material.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/wallet.dart';

class HiddenWithWallet extends StatelessWidget {
  const HiddenWithWallet({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Wallet?>(
        initialData: currentWalletBloc.wallet,
        stream: currentWalletBloc.outWallet,
        builder: (BuildContext context,
            AsyncSnapshot<Wallet?> currentWalletSnapshot) {
          return currentWalletSnapshot.data == null
              ? child
              : const SizedBox.shrink();
        });
  }
}
