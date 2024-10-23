import 'package:flutter/material.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/views/nfts/nft_receive/common/nft_receive_card.dart';

class NftReceiveDesktopView extends StatelessWidget {
  final Coin coin;
  final String? currentAddress;
  final void Function(String?) onAddressChanged;

  const NftReceiveDesktopView({
    super.key,
    required this.coin,
    required this.currentAddress,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: NftReceiveCard(
        currentAddress: currentAddress,
        qrCodeSize: 200,
        onAddressChanged: onAddressChanged,
        coin: coin,
      ),
    );
  }
}
