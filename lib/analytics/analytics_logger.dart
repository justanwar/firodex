import 'package:web_dex/analytics/analytics_events.dart';
import 'package:web_dex/analytics/analytics_service.dart';

/// Responsible for logging analytics events
class AnalyticsLogger {
  AnalyticsLogger(this._analyticsService);

  final AnalyticsService _analyticsService;
  bool _isActive = false;

  bool get isActive => _isActive;

  Future<void> activate() async {
    _isActive = true;
    await _analyticsService.initialize();
  }

  Future<void> deactivate() async {
    _isActive = false;
    await _analyticsService.disable();
  }

  /// Log an analytics event
  Future<void> logEvent(AnalyticsEventData event) async {
    if (!_isActive) return;

    await _analyticsService.logEvent(event.name, event.parameters);
  }
}
