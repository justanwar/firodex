import 'package:web_dex/mm2/mm2_api/rpc/base.dart';

class EnableSiaStatusRequest implements BaseRequest {
  EnableSiaStatusRequest({
    required this.taskId,
    this.forgetIfFinished = false,
  });

  final int taskId;
  final bool forgetIfFinished;

  @override
  late String userpass;

  @override
  final String method = 'task::enable_sia::status';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userpass': userpass,
      'mmrpc': '2.0',
      'method': method,
      'params': {
        'task_id': taskId,
        'forget_if_finished': forgetIfFinished,
      },
    };
  }
}
