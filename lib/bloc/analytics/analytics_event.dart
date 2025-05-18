// filepath: /Users/charl/Code/UTXO/komodo-wallet/lib/bloc/analytics/analytics_event.dart
abstract class AnalyticsEvent {
  const AnalyticsEvent();
}

class AnalyticsActivateEvent extends AnalyticsEvent {
  const AnalyticsActivateEvent();
}

class AnalyticsDeactivateEvent extends AnalyticsEvent {
  const AnalyticsDeactivateEvent();
}
