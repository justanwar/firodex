import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:web_dex/bloc/trezor_bloc/trezor_repo.dart';
import 'package:web_dex/blocs/current_wallet_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/bloc_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/balance/trezor_balance_init/trezor_balance_init_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/get_new_address/get_new_address_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/withdraw/trezor_withdraw/trezor_withdraw_request.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_type.dart';
import 'package:web_dex/model/hd_account/hd_account.dart';
import 'package:web_dex/model/hw_wallet/init_trezor.dart';
import 'package:web_dex/model/hw_wallet/trezor_progress_status.dart';
import 'package:web_dex/model/hw_wallet/trezor_status.dart';
import 'package:web_dex/model/hw_wallet/trezor_task.dart';
import 'package:web_dex/model/text_error.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/model/withdraw_details/withdraw_details.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/views/common/hw_wallet_dialog/show_trezor_passphrase_dialog.dart';
import 'package:web_dex/views/common/hw_wallet_dialog/show_trezor_pin_dialog.dart';

class TrezorCoinsBloc {
  TrezorCoinsBloc({
    required TrezorRepo trezorRepo,
    required CurrentWalletBloc walletRepo,
  })  : _trezorRepo = trezorRepo,
        _walletRepo = walletRepo;

  final TrezorRepo _trezorRepo;
  final CurrentWalletBloc _walletRepo;
  bool get _loggedInTrezor =>
      _walletRepo.wallet?.config.type == WalletType.trezor;
  Timer? _initNewAddressStatusTimer;

  Future<List<HdAccount>?> getAccounts(Coin coin) async {
    final TrezorBalanceInitResponse initResponse =
        await _trezorRepo.initBalance(coin);
    final int? taskId = initResponse.result?.taskId;
    if (taskId == null) return null;

    final int started = nowMs;
    // todo(yurii): change timeout to some reasonable value (10000?)
    while (nowMs - started < 100000) {
      final statusResponse = await _trezorRepo.getBalanceStatus(taskId);
      final InitTrezorStatus? status = statusResponse.result?.status;

      if (status == InitTrezorStatus.error) return null;

      if (status == InitTrezorStatus.ok) {
        return statusResponse.result?.balanceDetails?.accounts;
      }

      await Future<dynamic>.delayed(const Duration(milliseconds: 500));
    }

    return null;
  }

  Future<void> activateCoin(Coin coin) async {
    switch (coin.type) {
      case CoinType.utxo:
      case CoinType.smartChain:
        await _enableUtxo(coin);
        break;
      default:
        {}
    }
  }

  Future<void> _enableUtxo(Coin coin) async {
    final enableResponse = await _trezorRepo.enableUtxo(coin);
    final taskId = enableResponse.result?.taskId;
    if (taskId == null) return;

    while (_loggedInTrezor) {
      final statusResponse = await _trezorRepo.getEnableUtxoStatus(taskId);
      final InitTrezorStatus? status = statusResponse.result?.status;

      switch (status) {
        case InitTrezorStatus.error:
          coin.state = CoinState.suspended;
          return;

        case InitTrezorStatus.userActionRequired:
          final TrezorUserAction? action = statusResponse.result?.actionDetails;
          if (action == TrezorUserAction.enterTrezorPin) {
            await showTrezorPinDialog(TrezorTask(
              taskId: taskId,
              type: TrezorTaskType.enableUtxo,
            ));
          } else if (action == TrezorUserAction.enterTrezorPassphrase) {
            await showTrezorPassphraseDialog(TrezorTask(
              taskId: taskId,
              type: TrezorTaskType.enableUtxo,
            ));
          }
          break;

        case InitTrezorStatus.ok:
          final details = statusResponse.result?.details;
          if (details != null) {
            coin.accounts = details.accounts;
            coin.state = CoinState.active;
          }
          return;

        default:
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<int?> initNewAddress(Coin coin) async {
    final TrezorGetNewAddressInitResponse response =
        await _trezorRepo.initNewAddress(coin.abbr);
    final result = response.result;

    return result?.taskId;
  }

  Future<GetNewAddressResponse> getNewAddressStatus(
      int taskId, Coin coin) async {
    final GetNewAddressResponse response =
        await _trezorRepo.getNewAddressStatus(taskId);
    final GetNewAddressStatus? status = response.result?.status;
    final GetNewAddressResultDetails? details = response.result?.details;
    if (status == GetNewAddressStatus.ok &&
        details is GetNewAddressResultOkDetails) {
      coin.accounts = await getAccounts(coin);
    }
    return response;
  }

  void subscribeOnNewAddressStatus(
    int taskId,
    Coin coin,
    Function(GetNewAddressResponse) callback,
  ) {
    _initNewAddressStatusTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      final GetNewAddressResponse initNewAddressStatus =
          await getNewAddressStatus(taskId, coin);
      callback(initNewAddressStatus);
    });
  }

  void unsubscribeFromNewAddressStatus() {
    _initNewAddressStatusTimer?.cancel();
    _initNewAddressStatusTimer = null;
  }

  Future<void> cancelGetNewAddress(int taskId) async {
    await _trezorRepo.cancelGetNewAddress(taskId);
  }

  Future<BlocResponse<WithdrawDetails, BaseError>> withdraw(
    TrezorWithdrawRequest request, {
    required void Function(TrezorProgressStatus?) onProgressUpdated,
  }) async {
    final withdrawResponse = await _trezorRepo.withdraw(request);

    if (withdrawResponse.error != null) {
      return BlocResponse(
        result: null,
        error: TextError(error: withdrawResponse.error!),
      );
    }

    final int? taskId = withdrawResponse.result?.taskId;
    if (taskId == null) {
      return BlocResponse(
        result: null,
        error: TextError(error: LocaleKeys.somethingWrong.tr()),
      );
    }

    final int started = nowMs;
    while (nowMs - started < 1000 * 60 * 3) {
      final statusResponse = await _trezorRepo.getWithdrawStatus(taskId);

      if (statusResponse.error != null) {
        return BlocResponse(
          result: null,
          error: TextError(error: statusResponse.error!),
        );
      }

      final InitTrezorStatus? status = statusResponse.result?.status;

      switch (status) {
        case InitTrezorStatus.error:
          return BlocResponse(
            result: null,
            error: TextError(
                error: statusResponse.result?.errorDetails?.error ??
                    LocaleKeys.somethingWrong.tr()),
          );

        case InitTrezorStatus.inProgress:
          final TrezorProgressStatus? progressDetails =
              statusResponse.result?.progressDetails;

          onProgressUpdated(progressDetails);
          break;

        case InitTrezorStatus.userActionRequired:
          final TrezorUserAction? action = statusResponse.result?.actionDetails;
          if (action == TrezorUserAction.enterTrezorPin) {
            await showTrezorPinDialog(TrezorTask(
              taskId: taskId,
              type: TrezorTaskType.withdraw,
            ));
          } else if (action == TrezorUserAction.enterTrezorPassphrase) {
            await showTrezorPassphraseDialog(TrezorTask(
              taskId: taskId,
              type: TrezorTaskType.enableUtxo,
            ));
          }
          break;

        case InitTrezorStatus.ok:
          return BlocResponse(
            result: statusResponse.result?.details,
            error: null,
          );

        default:
      }

      await Future<dynamic>.delayed(const Duration(milliseconds: 500));
    }

    await _withdrawCancel(taskId);
    return BlocResponse(
      result: null,
      error: TextError(error: LocaleKeys.timeout.tr()),
    );
  }

  Future<void> _withdrawCancel(int taskId) async {
    await _trezorRepo.cancelWithdraw(taskId);
  }
}
