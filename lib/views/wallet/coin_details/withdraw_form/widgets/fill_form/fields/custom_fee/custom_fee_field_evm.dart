import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/shared/constants.dart';
import 'package:web_dex/shared/ui/custom_numeric_text_form_field.dart';

class CustomFeeFieldEVM extends StatefulWidget {
  @override
  State<CustomFeeFieldEVM> createState() => _CustomFeeFieldEVMState();
}

class _CustomFeeFieldEVMState extends State<CustomFeeFieldEVM> {
  final TextEditingController _gasLimitController = TextEditingController();
  final TextEditingController _gasPriceController = TextEditingController();
  TextSelection _gasLimitSelection = const TextSelection.collapsed(offset: 0);
  TextSelection _gasPriceSelection = const TextSelection.collapsed(offset: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildGasLimitField(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildGasPriceField(),
        ),
      ],
    );
  }

  Widget _buildGasLimitField() {
    return BlocSelector<WithdrawFormBloc, WithdrawFormState, String>(
      selector: (state) {
        return state.gasLimitError.message;
      },
      builder: (context, error) {
        return BlocSelector<WithdrawFormBloc, WithdrawFormState, String>(
          selector: (state) {
            return state.customFee.gas?.toString() ?? '';
          },
          builder: (context, gasLimit) {
            _gasLimitController
              ..text = gasLimit
              ..selection = _gasLimitSelection;
            return CustomNumericTextFormField(
              controller: _gasLimitController,
              validationMode: InputValidationMode.aggressive,
              validator: (_) {
                if (error.isEmpty) return null;
                return error;
              },
              onChanged: (_) {
                _change();
              },
              filteringRegExp: r'^(|[1-9]\d*)$',
              style: _style,
              hintText: LocaleKeys.gasLimit.tr(),
              hintTextStyle: _hintTextStyle,
            );
          },
        );
      },
    );
  }

  Widget _buildGasPriceField() {
    return BlocSelector<WithdrawFormBloc, WithdrawFormState, String>(
        selector: (state) {
      return state.gasLimitError.message;
    }, builder: (context, error) {
      return BlocSelector<WithdrawFormBloc, WithdrawFormState, String>(
        selector: (state) {
          return state.customFee.gasPrice ?? '';
        },
        builder: (context, gasPrice) {
          final String price = gasPrice;

          _gasPriceController
            ..text = price
            ..selection = _gasPriceSelection;
          return CustomNumericTextFormField(
            controller: _gasPriceController,
            validationMode: InputValidationMode.aggressive,
            validator: (_) {
              if (error.isEmpty) return null;
              return error;
            },
            onChanged: (_) {
              _change();
            },
            filteringRegExp: numberRegExp.pattern,
            style: _style,
            hintText: LocaleKeys.gasPriceGwei.tr(),
            hintTextStyle: _hintTextStyle,
          );
        },
      );
    });
  }

  void _change() {
    setState(() {
      _gasLimitSelection = _gasLimitController.selection;
      _gasPriceSelection = _gasPriceController.selection;
    });
    context.read<WithdrawFormBloc>().add(
          WithdrawFormCustomEvmFeeChanged(
            gas: double.tryParse(_gasLimitController.text)?.toInt(),
            gasPrice: _gasPriceController.text,
          ),
        );
  }
}

const _style = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
);
const _hintTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
);
