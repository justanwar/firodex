class InitTrezorReq {
  InitTrezorReq({this.devicePubkey});

  static const String method = 'task::init_trezor::init';
  final String? devicePubkey;
  late String userpass;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'mmrpc': '2.0',
      'params': {
        if (devicePubkey != null) 'device_pubkey': devicePubkey,
      }
    };
  }
}
