import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_dex/analytics/analytics_events.dart';
import 'package:web_dex/analytics/analytics_factory.dart';
import 'package:web_dex/analytics/analytics_logger.dart';
import 'package:web_dex/analytics/analytics_service.dart';
import 'package:web_dex/bloc/analytics/analytics_repo.dart';
import 'package:web_dex/model/settings/analytics_settings.dart';

class MockAnalyticsLogger extends Mock implements AnalyticsLogger {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAnalyticsSettings extends Mock implements AnalyticsSettings {}

void main() {
  late AnalyticsRepoImpl repo;
  late MockAnalyticsLogger mockLogger;
  late MockAnalyticsSettings mockSettings;

  setUp(() {
    mockLogger = MockAnalyticsLogger();
    mockSettings = MockAnalyticsSettings();

    when(() => mockSettings.isSendAllowed).thenReturn(true);

    // Stub the logger methods
    when(() => mockLogger.activate()).thenAnswer((_) async {});
    when(() => mockLogger.deactivate()).thenAnswer((_) async {});
    when(() => mockLogger.logEvent(any())).thenAnswer((_) async {});
    when(() => mockLogger.isActive).thenReturn(true);
  });

  group('AnalyticsRepo', () {
    test('should activate analytics when settings allow it', () async {
      // Arrange
      when(() => mockSettings.isSendAllowed).thenReturn(true);

      // Act
      repo = AnalyticsRepoImpl(mockSettings);

      // Assert
      verify(() => mockLogger.activate()).called(1);
    });

    test('should not activate analytics when settings do not allow it',
        () async {
      // Arrange
      when(() => mockSettings.isSendAllowed).thenReturn(false);

      // Act
      repo = AnalyticsRepoImpl(mockSettings);

      // Assert
      verifyNever(() => mockLogger.activate());
    });

    test('isActive should return logger active state', () {
      // Arrange
      when(() => mockLogger.isActive).thenReturn(true);
      repo = AnalyticsRepoImpl(mockSettings);

      // Act & Assert
      expect(repo.isActive, isTrue);
    });

    test('activate should call logger activate', () async {
      // Arrange
      repo = AnalyticsRepoImpl(mockSettings);

      // Act
      await repo.activate();

      // Assert
      verify(() => mockLogger.activate()).called(1);
    });

    test('deactivate should call logger deactivate', () async {
      // Arrange
      repo = AnalyticsRepoImpl(mockSettings);

      // Act
      await repo.deactivate();

      // Assert
      verify(() => mockLogger.deactivate()).called(1);
    });

    test('logEvent should call logger logEvent', () async {
      // Arrange
      repo = AnalyticsRepoImpl(mockSettings);
      final event = AnalyticsEvents.appOpened(
        platform: 'iOS',
        appVersion: '1.0.0',
      );

      // Act
      await repo.logEvent(event);

      // Assert
      verify(() => mockLogger.logEvent(event)).called(1);
    });
  });
}
