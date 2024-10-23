import 'package:web_dex/3p_api/faucet/faucet_response.dart';

abstract class FaucetState {
  const FaucetState();
}

class FaucetInitial extends FaucetState {
  const FaucetInitial();
}

class FaucetLoading extends FaucetState {
  const FaucetLoading();
}

class FaucetSuccess extends FaucetState {
  final FaucetResponse response;

  const FaucetSuccess(this.response);
}

class FaucetError extends FaucetState {
  final String message;

  const FaucetError(this.message);
}
