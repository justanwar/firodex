class TrezorWithdrawStatusRequest {
  TrezorWithdrawStatusRequest({required this.taskId});

  static const String method = 'task::withdraw::status';
  late String userpass;
  final int taskId;

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
