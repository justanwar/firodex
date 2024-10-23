import 'package:flutter/material.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/mm2/rpc/nft_transaction/nft_transactions_response.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/shared/widgets/hash_explorer_link.dart';

class NftTxnHash extends StatelessWidget {
  const NftTxnHash({super.key, required this.transaction});
  final NftTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final coin = coinsBloc.getCoin(transaction.chain.coinAbbr());
    if (coin == null) return const SizedBox.shrink();
    return HashExplorerLink(
      coin: coin,
      hash: transaction.transactionHash,
      type: HashExplorerType.tx,
    );
  }
}
