class TrezorEnableUtxoResponse {
  TrezorEnableUtxoResponse({this.result, this.error});

  factory TrezorEnableUtxoResponse.fromJson(Map<String, dynamic> json) {
    return TrezorEnableUtxoResponse(
      result: TrezorEnableUtxoResult.fromJson(json['result']),
      error: json['error'],
    );
  }

  final TrezorEnableUtxoResult? result;
  final dynamic error;
}

class TrezorEnableUtxoResult {
  TrezorEnableUtxoResult({required this.taskId});

  static TrezorEnableUtxoResult? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return TrezorEnableUtxoResult(
      taskId: json['task_id'],
    );
  }

  final int taskId;
}
