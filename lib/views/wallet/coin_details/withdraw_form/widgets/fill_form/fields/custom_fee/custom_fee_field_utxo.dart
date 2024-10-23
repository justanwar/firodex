import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/constants.dart';
import 'package:web_dex/shared/ui/custom_numeric_text_form_field.dart';

class CustomFeeFieldUtxo extends StatefulWidget {
  @override
  State<CustomFeeFieldUtxo> createState() => _CustomFeeFieldUtxoState();
}

class _CustomFeeFieldUtxoState extends State<CustomFeeFieldUtxo> {
  final TextEditingController _feeController = TextEditingController();
  TextSelection _previousTextSelection =
      const TextSelection.collapsed(offset: 0);
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodyMedium?.color);

    return BlocSelector<WithdrawFormBloc, WithdrawFormState, BaseError>(
      selector: (state) {
        return state.utxoCustomFeeError;
      },
      builder: (context, customFeeError) {
        return BlocSelector<WithdrawFormBloc, WithdrawFormState, String?>(
          selector: (state) {
            return state.customFee.amount;
          },
          builder: (context, feeAmount) {
            final amount = feeAmount ?? '';
            _feeController
              ..text = amount
              ..selection = _previousTextSelection;

            return CustomNumericTextFormField(
              controller: _feeController,
              validationMode: InputValidationMode.aggressive,
              validator: (_) {
                if (customFeeError.message.isEmpty) return null;
                return customFeeError.message;
              },
              onChanged: (String? value) {
                setState(() {
                  _previousTextSelection = _feeController.selection;
                });
                context
                    .read<WithdrawFormBloc>()
                    .add(WithdrawFormCustomFeeChanged(amount: value ?? ''));
              },
              filteringRegExp: numberRegExp.pattern,
              style: style,
              hintText: LocaleKeys.customFeeCoin.tr(args: [
                Coin.normalizeAbbr(
                  context.read<WithdrawFormBloc>().state.coin.abbr,
                )
              ]),
              hintTextStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            );
          },
        );
      },
    );
  }
}
