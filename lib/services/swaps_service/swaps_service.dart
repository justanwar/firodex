import 'package:rational/rational.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_taker_vol/max_taker_vol_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_taker_vol/max_taker_vol_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_recent_swaps/my_recent_swaps_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_recent_swaps/my_recent_swaps_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/recover_funds_of_swap/recover_funds_of_swap_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/recover_funds_of_swap/recover_funds_of_swap_response.dart';
import 'package:web_dex/model/swap.dart';
import 'package:web_dex/shared/utils/utils.dart';

SwapsService swapsService = SwapsService();

class SwapsService {
  Future<List<Swap>?> getRecentSwaps(MyRecentSwapsRequest request) async {
    final MyRecentSwapsResponse? response =
        await mm2Api.getMyRecentSwaps(request);
    if (response == null) {
      return null;
    }

    return response.result.swaps;
  }

  Future<RecoverFundsOfSwapResponse?> recoverFundsOfSwap(String uuid) async {
    final RecoverFundsOfSwapRequest request =
        RecoverFundsOfSwapRequest(uuid: uuid);
    final RecoverFundsOfSwapResponse? response =
        await mm2Api.recoverFundsOfSwap(request);
    if (response != null) {
      log(
        response.toJson().toString(),
        path: 'swaps_service => recoverFundsOfSwap',
      );
    }
    return response;
  }

  Future<Rational?> getMaxTakerVolume(String coinAbbr) async {
    final MaxTakerVolResponse? response =
        await mm2Api.getMaxTakerVolume(MaxTakerVolRequest(coin: coinAbbr));
    if (response == null) {
      return null;
    }

    return fract2rat(response.result.toJson());
  }
}
