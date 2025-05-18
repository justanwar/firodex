import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:web_dex/analytics/analytics_service.dart';
import 'package:web_dex/firebase_options.dart';
import 'package:web_dex/shared/utils/utils.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService();

  late FirebaseAnalytics _instance;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _instance = FirebaseAnalytics.instance;
      _isInitialized = true;
      await _instance.setAnalyticsCollectionEnabled(true);
    } catch (e, s) {
      _isInitialized = false;
      log(
        e.toString(),
        path: 'analytics -> FirebaseAnalyticsService -> initialize',
        trace: s,
        isError: true,
      );
    }
  }

  @override
  Future<void> disable() async {
    if (!_isInitialized) return;

    try {
      await _instance.setAnalyticsCollectionEnabled(false);
    } catch (e, s) {
      log(
        e.toString(),
        path: 'analytics -> FirebaseAnalyticsService -> disable',
        trace: s,
        isError: true,
      );
    }
  }

  @override
  Future<void> logEvent(String eventName, JsonMap parameters) async {
    if (!_isInitialized) return;

    final sanitizedParameters = parameters.map((key, value) {
      return MapEntry(key, value.toString());
    });

    try {
      await _instance.logEvent(
        name: eventName,
        parameters: sanitizedParameters,
      );
    } catch (e, s) {
      log(
        e.toString(),
        path: 'analytics -> FirebaseAnalyticsService -> logEvent',
        trace: s,
        isError: true,
      );
    }
  }
}
