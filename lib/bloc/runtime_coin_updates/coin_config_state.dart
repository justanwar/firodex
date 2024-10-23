part of 'coin_config_bloc.dart';

class CoinConfigState extends Equatable {
  const CoinConfigState();

  @override
  List<Object?> get props => [];
}

class CoinConfigInitial extends CoinConfigState {
  const CoinConfigInitial();

  @override
  List<Object> get props => [];
}

/// The coin config is currently being loaded from disk or network.
class CoinConfigLoadInProgress extends CoinConfigState {
  const CoinConfigLoadInProgress();

  @override
  List<Object> get props => [];
}

/// The coin config has been successfully loaded.
/// [coins] is a list of [Coin] objects.
class CoinConfigLoadSuccess extends CoinConfigState {
  const CoinConfigLoadSuccess({
    required this.coins,
    this.updatedCommitHash,
  });

  final List<Coin> coins;

  final String? updatedCommitHash;

  @override
  List<Object?> get props => [coins, updatedCommitHash];
}

/// The coin config failed to load.
/// [error] is the error message.
class CoinConfigLoadFailure extends CoinConfigState {
  const CoinConfigLoadFailure({
    required this.error,
  });

  final String error;

  @override
  List<Object> get props => [error];
}
