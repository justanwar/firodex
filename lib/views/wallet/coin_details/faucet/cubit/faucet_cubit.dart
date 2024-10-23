import 'package:bloc/bloc.dart';
import 'package:web_dex/3p_api/faucet/faucet.dart' as api;
import 'package:web_dex/3p_api/faucet/faucet_response.dart';
import 'package:web_dex/views/wallet/coin_details/faucet/cubit/faucet_state.dart';

class FaucetCubit extends Cubit<FaucetState> {
  final String coinAbbr;
  final String? coinAddress;

  FaucetCubit({
    required this.coinAbbr,
    required this.coinAddress,
  }) : super(const FaucetInitial());

  Future<void> callFaucet() async {
    emit(const FaucetLoading());
    try {
      final FaucetResponse response =
          await api.callFaucet(coinAbbr, coinAddress!);
      if (response.status == FaucetStatus.error) {
        return emit(FaucetError(response.message));
      } else {
        return emit(FaucetSuccess(response));
      }
    } catch (error) {
      return emit(FaucetError(error.toString()));
    }
  }
}
