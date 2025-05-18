import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Interface for analytics service providers
abstract class AnalyticsService {
  Future<void> initialize();
  Future<void> disable();
  Future<void> logEvent(String eventName, JsonMap parameters);
}
