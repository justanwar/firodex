// filepath: /Users/charl/Code/UTXO/komodo-wallet/lib/bloc/analytics/analytics_repo.dart
import 'package:web_dex/analytics/analytics_events.dart';
import 'package:web_dex/analytics/analytics_logger.dart';
import 'package:web_dex/analytics/implementation/firebase_analytics_service.dart';
import 'package:web_dex/model/settings/analytics_settings.dart';

abstract class AnalyticsRepo {
  Future<void> logEvent(AnalyticsEventData event);
  Future<void> activate();
  Future<void> deactivate();
  bool get isActive;
}

class AnalyticsRepoImpl implements AnalyticsRepo {
  AnalyticsRepoImpl(AnalyticsSettings settings) {
    final analyticsService = FirebaseAnalyticsService();
    _logger = AnalyticsLogger(analyticsService);

    if (settings.isSendAllowed) {
      activate();
    }
  }

  late final AnalyticsLogger _logger;

  @override
  bool get isActive => _logger.isActive;

  @override
  Future<void> activate() => _logger.activate();

  @override
  Future<void> deactivate() => _logger.deactivate();

  @override
  Future<void> logEvent(AnalyticsEventData event) => _logger.logEvent(event);
}
