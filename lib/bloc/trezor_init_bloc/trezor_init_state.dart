import 'package:equatable/equatable.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/hw_wallet/init_trezor.dart';
import 'package:web_dex/model/text_error.dart';

class TrezorInitState extends Equatable {
  const TrezorInitState({
    required this.taskId,
    required this.authMode,
    required this.status,
    this.error,
    required this.inProgress,
  });
  static TrezorInitState initial() => const TrezorInitState(
        taskId: null,
        authMode: null,
        error: null,
        status: null,
        inProgress: false,
      );

  TrezorInitState copyWith({
    int? Function()? taskId,
    AuthorizeMode? Function()? authMode,
    TextError? Function()? error,
    InitTrezorStatusData? Function()? status,
    bool Function()? inProgress,
  }) =>
      TrezorInitState(
        taskId: taskId != null ? taskId() : this.taskId,
        authMode: authMode != null ? authMode() : this.authMode,
        status: status != null ? status() : this.status,
        error: error != null ? error() : this.error,
        inProgress: inProgress != null ? inProgress() : this.inProgress,
      );

  final int? taskId;
  final AuthorizeMode? authMode;
  final InitTrezorStatusData? status;
  final TextError? error;
  final bool inProgress;

  @override
  List<Object?> get props => [taskId, authMode, status, error, inProgress];
}
