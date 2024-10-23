import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/bloc/runtime_coin_updates/runtime_update_config_provider.dart';
import 'package:web_dex/shared/utils/utils.dart';

part 'coin_config_event.dart';
part 'coin_config_state.dart';

/// A BLoC that manages the coin config state.
/// The BLoC fetches the coin configs from the repository and stores them
/// in the storage provider.
/// The BLoC emits the coin configs to the UI.
class CoinConfigBloc extends Bloc<CoinConfigEvent, CoinConfigState> {
  CoinConfigBloc({
    required this.coinsConfigRepo,
  }) : super(const CoinConfigState()) {
    on<CoinConfigLoadRequested>(_onLoadRequested);
    on<CoinConfigUpdateRequested>(_onUpdateRequested);
    on<CoinConfigUpdateSubscribeRequested>(_onPeriodicUpdateRequested);
    on<CoinConfigUpdateUnsubscribeRequested>(_onUnsubscribeRequested);
  }

  /// The repository that fetches the coins and coin configs.
  final CoinConfigRepository coinsConfigRepo;

  /// Full, platform-dependent, path to the app folder.
  String? _appFolderPath;
  Timer? _updateCoinConfigTimer;
  final _updateTime = const Duration(hours: 1);

  Future<void> _onLoadRequested(
    CoinConfigLoadRequested event,
    Emitter<CoinConfigState> emit,
  ) async {
    String? activeFetchedCommitHash;

    emit(const CoinConfigLoadInProgress());

    try {
      activeFetchedCommitHash = (state is CoinConfigLoadSuccess)
          ? (state as CoinConfigLoadSuccess).updatedCommitHash
          : await coinsConfigRepo.getCurrentCommit();

      _appFolderPath ??= await applicationDocumentsDirectory;
      await compute(updateCoinConfigs, _appFolderPath!);
    } catch (e) {
      emit(CoinConfigLoadFailure(error: e.toString()));
      log('Failed to update coin config: $e', isError: true);
      return;
    }

    final List<Coin> coins = (await coinsConfigRepo.getCoins())!;
    emit(
      CoinConfigLoadSuccess(
        coins: coins,
        updatedCommitHash: activeFetchedCommitHash,
      ),
    );
  }

  String? get stateActiveFetchedCommitHash {
    if (state is CoinConfigLoadSuccess) {
      return (state as CoinConfigLoadSuccess).updatedCommitHash;
    }
    return null;
  }

  Future<void> _onUpdateRequested(
    CoinConfigUpdateRequested event,
    Emitter<CoinConfigState> emit,
  ) async {
    String? currentCommit = stateActiveFetchedCommitHash;

    emit(const CoinConfigLoadInProgress());

    try {
      _appFolderPath ??= await applicationDocumentsDirectory;
      await compute(updateCoinConfigs, _appFolderPath!);
    } catch (e) {
      emit(CoinConfigLoadFailure(error: e.toString()));
      log('Failed to update coin config: $e', isError: true);
      return;
    }

    final List<Coin> coins = (await coinsConfigRepo.getCoins())!;
    emit(
      CoinConfigLoadSuccess(
        coins: coins,
        updatedCommitHash: currentCommit,
      ),
    );
  }

  Future<void> _onPeriodicUpdateRequested(
    CoinConfigUpdateSubscribeRequested event,
    Emitter<CoinConfigState> emit,
  ) async {
    _updateCoinConfigTimer = Timer.periodic(_updateTime, (timer) async {
      add(CoinConfigUpdateRequested());
    });
  }

  void _onUnsubscribeRequested(
    CoinConfigUpdateUnsubscribeRequested event,
    Emitter<CoinConfigState> emit,
  ) {
    _updateCoinConfigTimer?.cancel();
    _updateCoinConfigTimer = null;
  }
}

Future<void> updateCoinConfigs(String appFolderPath) async {
  final RuntimeUpdateConfigProvider runtimeUpdateConfigProvider =
      RuntimeUpdateConfigProvider();
  final CoinConfigRepository repo = CoinConfigRepository.withDefaults(
    await runtimeUpdateConfigProvider.getRuntimeUpdateConfig(),
  );
  // On native platforms, Isolates run in a separate process, so we need to
  // ensure that the Hive Box is initialized in the isolate.
  if (!kIsWeb) {
    final isMainThread = Isolate.current.debugName == 'main';
    if (!isMainThread) {
      KomodoCoinUpdater.ensureInitializedIsolate(appFolderPath);
    }
  }

  final bool isUpdated = await repo.isLatestCommit();

  Stopwatch stopwatch = Stopwatch()..start();

  if (!isUpdated) {
    await repo.updateCoinConfig(
      excludedAssets: excludedAssetList,
    );
  }

  log('Coin config updated in ${stopwatch.elapsedMilliseconds}ms');
  stopwatch.stop();
}
