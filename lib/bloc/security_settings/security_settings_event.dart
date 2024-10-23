import 'package:equatable/equatable.dart';

abstract class SecuritySettingsEvent extends Equatable {
  const SecuritySettingsEvent();

  @override
  List<Object> get props => [];
}

class ResetEvent extends SecuritySettingsEvent {
  const ResetEvent();
}

class ShowSeedEvent extends SecuritySettingsEvent {
  const ShowSeedEvent();
}

class SeedConfirmEvent extends SecuritySettingsEvent {
  const SeedConfirmEvent();
}

class SeedConfirmedEvent extends SecuritySettingsEvent {
  const SeedConfirmedEvent();
}

class ShowSeedWordsEvent extends SecuritySettingsEvent {
  const ShowSeedWordsEvent(this.isShow);
  final bool isShow;
}

class ShowSeedCopiedEvent extends SecuritySettingsEvent {
  const ShowSeedCopiedEvent();
}

class PasswordUpdateEvent extends SecuritySettingsEvent {
  const PasswordUpdateEvent();
}
