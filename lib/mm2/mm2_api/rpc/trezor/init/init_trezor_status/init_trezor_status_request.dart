class InitTrezorStatusReq {
  InitTrezorStatusReq({required this.taskId});

  static const String method = 'task::init_trezor::status';
  final int taskId;
  late String userpass;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'mmrpc': '2.0',
      'params': {
        'task_id': taskId,
      }
    };
  }
}
