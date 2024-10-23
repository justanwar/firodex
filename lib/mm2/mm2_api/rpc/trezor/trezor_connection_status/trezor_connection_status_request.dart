class TrezorConnectionStatusRequest {
  TrezorConnectionStatusRequest({
    required this.pubKey,
  });

  static const String method = 'trezor_connection_status';
  late String userpass;
  final String pubKey;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'mmrpc': '2.0',
      'params': {
        'device_pubkey': pubKey,
      }
    };
  }
}
