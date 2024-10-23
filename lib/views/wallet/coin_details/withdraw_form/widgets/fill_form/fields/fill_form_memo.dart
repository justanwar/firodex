import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

class FillFormMemo extends StatelessWidget {
  const FillFormMemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UiTextFormField(
      key: const Key('withdraw-form-memo-field'),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      enableInteractiveSelection: true,
      onChanged: (String? memo) {
        context
            .read<WithdrawFormBloc>()
            .add(WithdrawFormMemoUpdated(text: memo));
      },
      inputFormatters: [LengthLimitingTextInputFormatter(256)],
      maxLength: 256,
      counterText: '',
      hintText: LocaleKeys.memoOptional.tr(),
      hintTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
