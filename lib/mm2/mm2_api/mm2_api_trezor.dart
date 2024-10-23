import 'dart:convert';

import 'package:web_dex/mm2/mm2_api/rpc/trezor/balance/trezor_balance_init/trezor_balance_init_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/balance/trezor_balance_init/trezor_balance_init_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/balance/trezor_balance_status/trezor_balance_status_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/balance/trezor_balance_status/trezor_balance_status_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/enable_utxo/trezor_enable_utxo/trezor_enable_utxo_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/enable_utxo/trezor_enable_utxo/trezor_enable_utxo_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/enable_utxo/trezor_enable_utxo_status/trezor_enable_utxo_status_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/enable_utxo/trezor_enable_utxo_status/trezor_enable_utxo_status_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/get_new_address/get_new_address_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/get_new_address/get_new_address_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/init/init_trezor/init_trezor_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/init/init_trezor/init_trezor_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/init/init_trezor_cancel/init_trezor_cancel_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/init/init_trezor_status/init_trezor_status_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/init/init_trezor_status/init_trezor_status_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/trezor_connection_status/trezor_connection_status_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/trezor_passphrase/trezor_passphrase_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/trezor_pin/trezor_pin_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/withdraw/trezor_withdraw/trezor_withdraw_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/withdraw/trezor_withdraw/trezor_withdraw_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/withdraw/trezor_withdraw_cancel/trezor_withdraw_cancel_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/withdraw/trezor_withdraw_status/trezor_withdraw_status_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trezor/withdraw/trezor_withdraw_status/trezor_withdraw_status_response.dart';
import 'package:web_dex/model/hw_wallet/trezor_connection_status.dart';
import 'package:web_dex/shared/utils/utils.dart';

class Mm2ApiTrezor {
  Mm2ApiTrezor(this.call);

  final Future<dynamic> Function(dynamic) call;

  Future<InitTrezorRes> init(InitTrezorReq request) async {
    try {
      final String response = await call(request);
      return InitTrezorRes.fromJson(jsonDecode(response));
    } catch (e) {
      return InitTrezorRes(
        error: e.toString(),
      );
    }
  }

  Future<InitTrezorStatusRes> initStatus(InitTrezorStatusReq request) async {
    try {
      final String response = await call(request);
      return InitTrezorStatusRes.fromJson(jsonDecode(response));
    } catch (e) {
      return InitTrezorStatusRes(error: e.toString());
    }
  }

  Future<void> initCancel(InitTrezorCancelReq request) async {
    try {
      await call(request);
    } catch (e) {
      log(e.toString(), path: 'api => initTrezorCancel', isError: true);
    }
  }

  Future<void> pin(TrezorPinRequest request) async {
    try {
      await call(request);
    } catch (e) {
      log(e.toString(), path: 'api => trezorPin', isError: true);
    }
  }

  Future<void> passphrase(TrezorPassphraseRequest request) async {
    try {
      await call(request);
    } catch (e) {
      log(e.toString(), path: 'api => trezorPassphrase', isError: true);
    }
  }

  Future<TrezorEnableUtxoResponse> enableUtxo(
      TrezorEnableUtxoReq request) async {
    try {
      final String response = await call(request);
      return TrezorEnableUtxoResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorEnableUtxoResponse(error: e.toString());
    }
  }

  Future<TrezorEnableUtxoStatusResponse> enableUtxoStatus(
      TrezorEnableUtxoStatusReq request) async {
    try {
      final String response = await call(request);
      return TrezorEnableUtxoStatusResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorEnableUtxoStatusResponse(error: e.toString());
    }
  }

  Future<TrezorBalanceInitResponse> balanceInit(
      TrezorBalanceInitRequest request) async {
    try {
      final String response = await call(request);
      return TrezorBalanceInitResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorBalanceInitResponse(error: e.toString());
    }
  }

  Future<TrezorBalanceStatusResponse> balanceStatus(
      TrezorBalanceStatusRequest request) async {
    try {
      final String response = await call(request);
      return TrezorBalanceStatusResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorBalanceStatusResponse(error: e.toString());
    }
  }

  Future<TrezorGetNewAddressInitResponse> initNewAddress(String coin) async {
    try {
      final String response =
          await call(TrezorGetNewAddressInitReq(coin: coin));
      return TrezorGetNewAddressInitResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorGetNewAddressInitResponse(error: e.toString());
    }
  }

  Future<GetNewAddressResponse> getNewAddressStatus(int taskId) async {
    try {
      final String response =
          await call(TrezorGetNewAddressStatusReq(taskId: taskId));
      return GetNewAddressResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return GetNewAddressResponse(error: e.toString());
    }
  }

  Future<void> cancelGetNewAddress(int taskId) async {
    try {
      await call(TrezorGetNewAddressCancelReq(taskId: taskId));
    } catch (e) {
      log(e.toString(), path: 'api_trezor => getNewAddressCancel');
    }
  }

  Future<TrezorWithdrawResponse> withdraw(TrezorWithdrawRequest request) async {
    try {
      final String response = await call(request);
      return TrezorWithdrawResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorWithdrawResponse(error: e.toString());
    }
  }

  Future<TrezorWithdrawStatusResponse> withdrawStatus(
      TrezorWithdrawStatusRequest request) async {
    try {
      final String response = await call(request);
      return TrezorWithdrawStatusResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return TrezorWithdrawStatusResponse(error: e.toString());
    }
  }

  Future<void> withdrawCancel(TrezorWithdrawCancelRequest request) async {
    try {
      await call(request);
    } catch (e) {
      log(e.toString(), path: 'api => withdrawCancel', isError: true);
    }
  }

  Future<TrezorConnectionStatus> getConnectionStatus(String pubKey) async {
    try {
      final String response =
          await call(TrezorConnectionStatusRequest(pubKey: pubKey));
      final Map<String, dynamic> responseJson = jsonDecode(response);
      final String? status = responseJson['result']?['status'];
      if (status == null) return TrezorConnectionStatus.unknown;
      return TrezorConnectionStatus.fromString(status);
    } catch (e, s) {
      log(
        'Error getting trezor status: ${e.toString()}',
        path: 'api => trezorConnectionStatus',
        trace: s,
        isError: true,
      );
      return TrezorConnectionStatus.unknown;
    }
  }
}
