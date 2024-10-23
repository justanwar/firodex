class TrezorGetNewAddressInitReq {
  TrezorGetNewAddressInitReq({required this.coin});

  static const String method = 'task::get_new_address::init';
  late String userpass;
  final String coin;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'mmrpc': '2.0',
      'params': {
        'coin': coin,
        'account_id': 0,
        'chain': 'External',
        'gap_limit': 20,
      }
    };
  }
}

class TrezorGetNewAddressStatusReq {
  TrezorGetNewAddressStatusReq({required this.taskId});

  static const String method = 'task::get_new_address::status';
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

class TrezorGetNewAddressCancelReq {
  TrezorGetNewAddressCancelReq({required this.taskId});

  static const String method = 'task::get_new_address::cancel';
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
