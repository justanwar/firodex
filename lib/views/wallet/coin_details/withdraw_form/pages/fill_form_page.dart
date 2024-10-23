import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/views/wallet/coin_details/constants.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fields/custom_fee/fill_form_custom_fee.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fields/fill_form_amount.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fields/fill_form_memo.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fields/fill_form_recipient_address.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fields/fill_form_trezor_sender_address.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fill_form_error.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fill_form_footer.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/fill_form/fill_form_title.dart';

class FillFormPage extends StatelessWidget {
  const FillFormPage();

  @override
  Widget build(BuildContext context) {
    final double maxWidth = isMobile ? double.infinity : withdrawWidth;
    final state = context.watch<WithdrawFormBloc>().state;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FillFormTitle(state.coin.abbr),
              const SizedBox(height: 28),
              if (state.coin.enabledType == WalletType.trezor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: FillFormTrezorSenderAddress(
                    coin: state.coin,
                    addresses: state.senderAddresses,
                    selectedAddress: state.selectedSenderAddress,
                  ),
                ),
              FillFormRecipientAddress(),
              const SizedBox(height: 20),
              FillFormAmount(),
              if (state.coin.isTxMemoSupported)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: FillFormMemo(),
                ),
              if (state.coin.isCustomFeeSupported)
                Padding(
                  padding: const EdgeInsets.only(top: 9.0),
                  child: FillFormCustomFee(),
                ),
              const SizedBox(height: 10),
              const FillFormError(),
            ],
          ),
          const SizedBox(height: 10),
          FillFormFooter(),
        ],
      ),
    );
  }
}
