import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_bloc.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';

class SendConfirmFormError extends StatelessWidget {
  const SendConfirmFormError();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WithdrawFormBloc, WithdrawFormState>(
        builder: (BuildContext context, WithdrawFormState state) {
      final BaseError sendError = state.sendError;

      return Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        width: double.infinity,
        child: Text(
          sendError.message,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    });
  }
}
