class TrezorWithdrawResponse {
  TrezorWithdrawResponse({this.result, this.error});

  factory TrezorWithdrawResponse.fromJson(Map<String, dynamic> json) {
    return TrezorWithdrawResponse(
      result: TrezorWithdrawResult.fromJson(json['result']),
      error: json['error'],
    );
  }

  String? error;
  TrezorWithdrawResult? result;
}

class TrezorWithdrawResult {
  TrezorWithdrawResult({required this.taskId});

  static TrezorWithdrawResult? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return TrezorWithdrawResult(taskId: json['task_id']);
  }

  final int taskId;
}
