import 'dart:async';
import 'package:bloc/bloc.dart';
import 'system_health_event.dart';
import 'system_health_state.dart';
import 'package:web_dex/shared/utils/utils.dart';

class SystemHealthBloc extends Bloc<SystemHealthEvent, SystemHealthState> {
  SystemHealthBloc() : super(SystemHealthInitial()) {
    on<CheckSystemClock>(_onCheckSystemClock);
    _startPeriodicCheck();
  }

  Timer? _timer;

  void _startPeriodicCheck() {
    add(CheckSystemClock());

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      add(CheckSystemClock());
    });
  }

  Future<void> _onCheckSystemClock(
    CheckSystemClock event,
    Emitter<SystemHealthState> emit,
  ) async {
    emit(SystemHealthLoadInProgress());
    try {
      emit(SystemHealthLoadSuccess(await systemClockIsValid()));
    } catch (_) {
      emit(SystemHealthLoadFailure());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
