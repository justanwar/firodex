part of 'package:web_dex/main.dart';

final class AppBootstrapper {
  AppBootstrapper._();

  static AppBootstrapper get instance => _instance;

  static final _instance = AppBootstrapper._();

  bool _isInitialized = false;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    final timer = Stopwatch()..start();
    await logger.init();

    log('AppBootstrapper: Log initialized in ${timer.elapsedMilliseconds}ms');
    timer.reset();

    await _warmUpInitializers.awaitAll();
    log('AppBootstrapper: Warm-up initializers completed in ${timer.elapsedMilliseconds}ms');
    timer.stop();

    _isInitialized = true;
  }

  /// A list of futures that should be completed before the app starts
  /// ([runApp]) which do not depend on each other.
  final List<Future<void>> _warmUpInitializers = [
    app_bloc_root.loadLibrary(),
    packageInformation.init(),
    EasyLocalization.ensureInitialized(),
    CexMarketData.ensureInitialized(),
    PlatformTuner.setWindowTitleAndSize(),
    startUpBloc.run(),
    SettingsRepository.loadStoredSettings()
        .then((stored) => _storedSettings = stored),
    RuntimeUpdateConfigProvider()
        .getRuntimeUpdateConfig()
        .then((config) => _runtimeUpdateConfig = config),
    KomodoCoinUpdater.ensureInitialized(appFolder)
        .then((_) => sparklineRepository.init()),
  ];
}

StoredSettings? _storedSettings;
RuntimeUpdateConfig? _runtimeUpdateConfig;
