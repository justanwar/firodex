class TrezorBalanceInitResponse {
  TrezorBalanceInitResponse({this.result, this.error});

  factory TrezorBalanceInitResponse.fromJson(Map<String, dynamic> json) {
    return TrezorBalanceInitResponse(
      result: TrezorBalanceInitResult.fromJson(json['result']),
      error: json['error'],
    );
  }

  final TrezorBalanceInitResult? result;
  final dynamic error;
}

class TrezorBalanceInitResult {
  TrezorBalanceInitResult({required this.taskId});

  static TrezorBalanceInitResult? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return TrezorBalanceInitResult(
      taskId: json['task_id'],
    );
  }

  final int taskId;
}
