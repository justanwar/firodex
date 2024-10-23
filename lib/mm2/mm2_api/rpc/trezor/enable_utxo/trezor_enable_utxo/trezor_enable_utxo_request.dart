import 'package:web_dex/model/coin.dart';

class TrezorEnableUtxoReq {
  TrezorEnableUtxoReq({required this.coin});

  static const String method = 'task::enable_utxo::init';
  late String userpass;
  final Coin coin;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'mmrpc': '2.0',
      'params': {
        'ticker': coin.abbr,
        'activation_params': {
          'tx_history': true,
          'mode': {
            'rpc': 'Electrum',
            'rpc_data': {
              'servers': coin.electrum,
            },
          },
          'scan_policy': 'scan_if_new_wallet',
          'priv_key_policy': 'Trezor'
        }
      }
    };
  }
}
