import 'package:flutter/material.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/views/nfts/nft_receive/common/nft_receive_card.dart';

class NftReceiveMobileView extends StatelessWidget {
  final void Function(String?) onAddressChanged;
  final Coin coin;
  final String? currentAddress;
  const NftReceiveMobileView({
    Key? key,
    required this.onAddressChanged,
    required this.coin,
    required this.currentAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: NftReceiveCard(
        onAddressChanged: onAddressChanged,
        coin: coin,
        currentAddress: currentAddress,
        qrCodeSize: 260,
        maxWidth: double.infinity,
      ),
    );
  }
}
