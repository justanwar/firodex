class TrezorEnableUtxoStatusReq {
  TrezorEnableUtxoStatusReq({required this.taskId});

  static const String method = 'task::enable_utxo::status';
  late String userpass;
  final int taskId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userpass': userpass,
      'mmrpc': '2.0',
      'method': method,
      'params': {
        'task_id': taskId,
      }
    };
  }
}
