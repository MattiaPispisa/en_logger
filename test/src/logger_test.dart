import 'package:en_logger/en_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockHandler extends Mock implements EnLoggerHandler {}

void main() {
  group(
    'EnLogger',
    () {
      test('should create correctly', () {
        expect(EnLogger.new, returnsNormally);
      });

      test(
        'should manage handlers correctly',
        () {
          final mockHandler = _MockHandler();
          final logger = EnLogger()
            ..addHandler(mockHandler)
            ..debug('hy');

          verify(
            () => mockHandler.write(
              'hy',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: any(named: 'severity'),
              data: any(named: 'data'),
            ),
          ).called(1);

          logger
            ..removeHandler(mockHandler)
            ..critical('error');

          verifyNever(
            () => mockHandler.write(
              'error',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: any(named: 'severity'),
              data: any(named: 'data'),
            ),
          );

          logger
            ..addHandler(mockHandler)
            ..removeAllHandlers()
            ..debug('hy');

          verifyNever(
            () => mockHandler.write(
              'hy',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: any(named: 'severity'),
              data: any(named: 'data'),
            ),
          );
        },
      );

      test(
        'should write with correct data',
        () {
          final mockHandler = _MockHandler();
          final logger = EnLogger()
            ..addHandler(mockHandler)
            ..debug(
              'hy',
              prefix: 'prefix',
              data: [],
            );

          verify(
            () => mockHandler.write(
              'hy',
              prefix: 'prefix',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              data: [],
            ),
          ).called(1);

          logger.error('error');
          verify(
            () => mockHandler.write(
              'error',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.error,
            ),
          ).called(1);

          logger.info('info');
          verify(
            () => mockHandler.write(
              'info',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.informational,
            ),
          ).called(1);

          logger.critical('critical');
          verify(
            () => mockHandler.write(
              'critical',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.critical,
            ),
          ).called(1);
        },
      );

      test(
        'should handle instances correctly',
        () {
          final mockHandler = _MockHandler();
          final logger = EnLogger()..addHandler(mockHandler);

          logger.getConfiguredInstance(prefix: 'prefix').debug('debug');

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          ).called(1);

          logger.debug('debug');
          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
            ),
          ).called(1);
        },
      );
    },
  );
}
