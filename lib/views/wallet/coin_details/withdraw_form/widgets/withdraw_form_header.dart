import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/widgets/segwit_icon.dart';
import 'package:web_dex/views/common/page_header/page_header.dart';

class WithdrawFormHeader extends StatelessWidget {
  const WithdrawFormHeader({
    this.isIndicatorShown = true,
    required this.coin,
  });
  final bool isIndicatorShown;
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WithdrawFormBloc, WithdrawFormState>(
      builder: (context, WithdrawFormState state) {
        return PageHeader(
          title: state.step.title,
          widgetTitle: coin.mode == CoinMode.segwit
              ? const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: SegwitIcon(height: 22),
                )
              : null,
          backText: LocaleKeys.backToWallet.tr(),
          onBackButtonPressed: context.read<WithdrawFormBloc>().goBack,
        );
      },
    );
  }
}
