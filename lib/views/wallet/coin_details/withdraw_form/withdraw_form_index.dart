import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/views/common/pages/page_layout.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/pages/complete_page.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/pages/confirm_page.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/pages/failed_page.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/pages/fill_form_page.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/withdraw_form_header.dart';

class WithdrawFormIndex extends StatefulWidget {
  const WithdrawFormIndex({
    required this.coin,
    this.address,
    this.amount,
  });

  final Coin coin;
  final String? address;
  final String? amount;

  @override
  State<WithdrawFormIndex> createState() => _WithdrawFormIndexState();
}

class _WithdrawFormIndexState extends State<WithdrawFormIndex> {
  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      context.read<WithdrawFormBloc>().add(
            WithdrawFormAddressChanged(
              address: widget.address!,
            ),
          );
    }

    if (widget.amount != null) {
      context.read<WithdrawFormBloc>().add(
            WithdrawFormAmountChanged(
              amount: widget.amount!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return BlocSelector<WithdrawFormBloc, WithdrawFormState, WithdrawFormStep>(
      selector: (state) => state.step,
      builder: (context, step) => PageLayout(
        header: WithdrawFormHeader(coin: widget.coin),
        content: Flexible(
          child: DexScrollbar(
            isMobile: isMobile,
            scrollController: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Builder(
                  builder: (context) {
                    switch (step) {
                      case WithdrawFormStep.fill:
                        return const FillFormPage();
                      case WithdrawFormStep.confirm:
                        return const ConfirmPage();
                      case WithdrawFormStep.success:
                        return const CompletePage();
                      case WithdrawFormStep.failed:
                        return const FailedPage();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
