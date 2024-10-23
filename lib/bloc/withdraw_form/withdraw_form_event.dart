import 'package:equatable/equatable.dart';
import 'package:web_dex/bloc/withdraw_form/withdraw_form_step.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/model/hw_wallet/trezor_progress_status.dart';
import 'package:web_dex/model/withdraw_details/withdraw_details.dart';

abstract class WithdrawFormEvent extends Equatable {
  const WithdrawFormEvent();

  @override
  List<Object?> get props => [];
}

class WithdrawFormAddressChanged extends WithdrawFormEvent {
  const WithdrawFormAddressChanged({required this.address});
  final String address;

  @override
  List<Object?> get props => [address];
}

class WithdrawFormAmountChanged extends WithdrawFormEvent {
  const WithdrawFormAmountChanged({required this.amount});
  final String amount;

  @override
  List<Object?> get props => [amount];
}

class WithdrawFormCustomFeeChanged extends WithdrawFormEvent {
  const WithdrawFormCustomFeeChanged({required this.amount});
  final String amount;

  @override
  List<Object?> get props => [amount];
}

class WithdrawFormCustomEvmFeeChanged extends WithdrawFormEvent {
  const WithdrawFormCustomEvmFeeChanged({this.gasPrice, this.gas});
  final String? gasPrice;
  final int? gas;

  @override
  List<Object?> get props => [gasPrice, gas];
}

class WithdrawFormSenderAddressChanged extends WithdrawFormEvent {
  const WithdrawFormSenderAddressChanged({required this.address});
  final String address;

  @override
  List<Object?> get props => [address];
}

class WithdrawFormMaxTapped extends WithdrawFormEvent {
  const WithdrawFormMaxTapped({required this.isEnabled});
  final bool isEnabled;

  @override
  List<Object?> get props => [isEnabled];
}

class WithdrawFormWithdrawSuccessful extends WithdrawFormEvent {
  const WithdrawFormWithdrawSuccessful({required this.details});
  final WithdrawDetails details;

  @override
  List<Object?> get props => [details];
}

class WithdrawFormWithdrawFailed extends WithdrawFormEvent {
  const WithdrawFormWithdrawFailed({required this.error});
  final BaseError error;

  @override
  List<Object?> get props => [error];
}

class WithdrawFormTrezorStatusUpdated extends WithdrawFormEvent {
  const WithdrawFormTrezorStatusUpdated({required this.status});
  final TrezorProgressStatus? status;

  @override
  List<Object?> get props => [status];
}

class WithdrawFormSendRawTx extends WithdrawFormEvent {
  const WithdrawFormSendRawTx();

  @override
  List<Object?> get props => [];
}

class WithdrawFormCustomFeeDisabled extends WithdrawFormEvent {
  const WithdrawFormCustomFeeDisabled();

  @override
  List<Object?> get props => [];
}

class WithdrawFormCustomFeeEnabled extends WithdrawFormEvent {
  const WithdrawFormCustomFeeEnabled();

  @override
  List<Object?> get props => [];
}

class WithdrawFormConvertAddress extends WithdrawFormEvent {
  const WithdrawFormConvertAddress();

  @override
  List<Object?> get props => [];
}

class WithdrawFormSubmitted extends WithdrawFormEvent {
  const WithdrawFormSubmitted();
}

class WithdrawFormReset extends WithdrawFormEvent {
  const WithdrawFormReset();
}

class WithdrawFormStepReverted extends WithdrawFormEvent {
  const WithdrawFormStepReverted({required this.step});
  final WithdrawFormStep step;
}

class WithdrawFormMemoUpdated extends WithdrawFormEvent {
  const WithdrawFormMemoUpdated({required this.text});
  final String? text;
}
