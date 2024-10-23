abstract class SystemHealthState {}

class SystemHealthInitial extends SystemHealthState {}

class SystemHealthLoadInProgress extends SystemHealthState {}

class SystemHealthLoadSuccess extends SystemHealthState {
  final bool isValid;

  SystemHealthLoadSuccess(this.isValid);
}

class SystemHealthLoadFailure extends SystemHealthState {}
