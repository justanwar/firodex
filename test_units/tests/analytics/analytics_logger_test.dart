import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_dex/analytics/analytics_events.dart';
import 'package:web_dex/analytics/analytics_factory.dart';
import 'package:web_dex/analytics/analytics_logger.dart';
import 'package:web_dex/analytics/analytics_service.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late AnalyticsLogger logger;
  late MockAnalyticsService mockService;

  setUp(() {
    mockService = MockAnalyticsService();
    logger = AnalyticsLogger(mockService);

    // Stub the service methods
    when(() => mockService.initialize()).thenAnswer((_) async {});
    when(() => mockService.disable()).thenAnswer((_) async {});
    when(() => mockService.logEvent(any(), any())).thenAnswer((_) async {});
  });

  group('AnalyticsLogger', () {
    test('isActive should be false by default', () {
      // Assert
      expect(logger.isActive, isFalse);
    });

    test('activate should set isActive to true and initialize service',
        () async {
      // Act
      await logger.activate();

      // Assert
      expect(logger.isActive, isTrue);
      verify(() => mockService.initialize()).called(1);
    });

    test('deactivate should set isActive to false and disable service',
        () async {
      // Arrange
      await logger.activate();

      // Act
      await logger.deactivate();

      // Assert
      expect(logger.isActive, isFalse);
      verify(() => mockService.disable()).called(1);
    });

    test('logEvent should not call service when inactive', () async {
      // Arrange
      final event = AnalyticsEvents.appOpened(
        platform: 'iOS',
        appVersion: '1.0.0',
      );

      // Act
      await logger.logEvent(event);

      // Assert
      verifyNever(() => mockService.logEvent(any(), any()));
    });

    test('logEvent should call service with correct parameters when active',
        () async {
      // Arrange
      await logger.activate();
      final event = AnalyticsEvents.appOpened(
        platform: 'iOS',
        appVersion: '1.0.0',
      );

      // Act
      await logger.logEvent(event);

      // Assert
      verify(() => mockService.logEvent(
            event.name,
            event.parameters,
          )).called(1);
    });
  });
}
