part of 'coin_config_bloc.dart';

sealed class CoinConfigEvent extends Equatable {
  const CoinConfigEvent();

  @override
  List<Object> get props => [];
}

/// Request for the coin configs to be loaded from disk.
/// Emits [CoinConfigLoadInProgress] followed by [CoinConfigLoadSuccess] or
/// [CoinConfigLoadFailure].
final class CoinConfigLoadRequested extends CoinConfigEvent {}

/// Request for the coin configs to be updated from the repository.
/// Emits [CoinConfigLoadInProgress] followed by [CoinConfigLoadSuccess] or
/// [CoinConfigLoadFailure].
final class CoinConfigUpdateRequested extends CoinConfigEvent {}

/// Request for periodic updates of the coin configs.
final class CoinConfigUpdateSubscribeRequested extends CoinConfigEvent {}

/// Request to stop periodic updates of the coin configs.
final class CoinConfigUpdateUnsubscribeRequested extends CoinConfigEvent {}
