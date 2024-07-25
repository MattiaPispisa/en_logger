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
          registerFallbackValue(Severity.debug);
          final mockHandler = _MockHandler();
          final logger = EnLogger()
            ..addHandler(mockHandler)
            ..debug('hy');

          verify(
            () => mockHandler.write(
              'hy',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
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
              severity: Severity.critical,
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

          logger
            ..addHandlers([mockHandler])
            ..debug('jo');

          verify(
            () => mockHandler.write(
              'jo',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              data: any(named: 'data'),
            ),
          ).called(1);

          logger
            ..removeHandlers([mockHandler])
            ..debug('no write');
          verifyNever(
                () => mockHandler.write(
              'no write',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
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
              'debug',
              prefix: 'prefix',
              data: [],
            );
          verify(
            () => mockHandler.write(
              'debug',
              prefix: 'prefix',
              severity: Severity.debug,
              data: [],
            ),
          ).called(1);

          logger.info('info');
          verify(
            () => mockHandler.write(
              'info',
              severity: Severity.informational,
            ),
          ).called(1);

          logger.normal('notice');
          verify(
            () => mockHandler.write(
              'notice',
              severity: Severity.notice,
            ),
          ).called(1);

          logger.warning('warning');
          verify(
            () => mockHandler.write(
              'warning',
              severity: Severity.warning,
            ),
          ).called(1);

          logger.error('error');
          verify(
            () => mockHandler.write(
              'error',
              severity: Severity.error,
            ),
          ).called(1);

          logger.critical('critical');
          verify(
            () => mockHandler.write(
              'critical',
              severity: Severity.critical,
            ),
          ).called(1);

          logger.alert('alert');
          verify(
            () => mockHandler.write(
              'alert',
              severity: Severity.alert,
            ),
          ).called(1);

          logger.emergency('emergency');
          verify(
            () => mockHandler.write(
              'emergency',
              severity: Severity.emergency,
            ),
          ).called(1);
        },
      );

      test(
        'should handle EnLoggerData',
        () {
          final mockHandler = _MockHandler();
          final data = [
            const EnLoggerData(
              name: 'file.txt',
              content: '{count:3}',
              description: 'freezed serialized data',
            ),
          ];
          EnLogger()
            ..addHandler(mockHandler)
            ..debug(
              'debug',
              data: data,
            );

          verify(
            () => mockHandler.write(
              'debug',
              severity: Severity.debug,
              data: data,
            ),
          ).called(1);
        },
      );

      test(
        'should handle EnLogger instances correctly',
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
