import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockHandler extends Mock implements EnLoggerHandler {}

class _MockObject extends Mock implements Object {
  int toStringCalledCount = 0;

  @override
  String toString() {
    toStringCalledCount++;
    return super.toString();
  }
}

class _NoOpEnHandler extends EnLoggerHandler {
  int writeCalledCount = 0;

  @override
  void write(
    String message, {
    required Severity severity,
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  }) {
    writeCalledCount++;
    return;
  }
}

void main() {
  group(
    'EnLogger',
    () {
      test('should create correctly', () {
        expect(EnLogger.new, returnsNormally);
      });

      test('should "can" be default true', () {
        final handler = _NoOpEnHandler();
        EnLogger()
          ..addHandler(handler)
          ..debug('debug');

        expect(handler.writeCalledCount, 1);
      });

      test(
        'should manage handlers correctly',
        () async {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

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

      test('should toString() message only once', () {
        registerFallbackValue(Severity.debug);

        final mockObject = _MockObject();

        final mockHandler = _MockHandler();
        final secondMockHandler = _MockHandler();

        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        when(
          () => secondMockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        EnLogger()
          ..addHandlers([mockHandler, secondMockHandler])
          ..debug(mockObject);

        expect(mockObject.toStringCalledCount, 1);
        verify(
          () => mockHandler.write(
            any(),
            severity: Severity.debug,
            prefix: any(named: 'prefix'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
          ),
        ).called(1);
      });

      test(
        'should write with correct data',
        () {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

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
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

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
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          final logger = EnLogger()..addHandler(mockHandler);

          // debug is called from a new instance with default prefix "prefix"
          logger.getConfiguredInstance(prefix: 'prefix').debug('debug');
          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          ).called(1);

          // no prefix is passed and there isn't a default one
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

      test(
        'should handle EnLogger instances correctly'
        ' even without prefix override',
        () {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          final logger = EnLogger();

          // debug is called from a new instance with default prefix "prefix"
          logger.getConfiguredInstance()
            ..addHandler(mockHandler)
            ..debug('debug');
          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
            ),
          ).called(1);

          // no prefix is passed and there isn't a default one
          logger.debug('debug');
          verifyNever(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
            ),
          );
        },
      );

      test(
        'should handle EnLogger instances correctly',
        () {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          final secondMockHandler = _MockHandler();

          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          when(
            () => secondMockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          final logger = EnLogger()..addHandler(mockHandler);

          logger.getConfiguredInstance(prefix: 'prefix')
            ..addHandler(secondMockHandler)
            ..debug('debug');

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          ).called(1);
          verify(
            () => secondMockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          ).called(1);

          // secondMockHandler is not available in the first logger
          logger.debug('debug');
          verifyNever(
            () => secondMockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          );
        },
      );

      test('should handle nested instances correctly', () {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger()..addHandler(mockHandler);

        final instance = logger.getConfiguredInstance(prefix: 'prefix')
          ..debug('debug');

        instance.getConfiguredInstance(prefix: 'prefix2').debug('debug2');

        verify(
          () => mockHandler.write(
            'debug',
            stackTrace: any(named: 'stackTrace'),
            severity: Severity.debug,
            prefix: 'prefix',
          ),
        ).called(1);
        verify(
          () => mockHandler.write(
            'debug2',
            stackTrace: any(named: 'stackTrace'),
            severity: Severity.debug,
            prefix: 'prefix2',
          ),
        ).called(1);
      });

      test(
        'should handle EnLogger instances correctly',
        () {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          final secondMockHandler = _MockHandler();

          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          when(
            () => secondMockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          final logger = EnLogger()..addHandler(mockHandler);

          logger.getConfiguredInstance(prefix: 'prefix')
            ..addHandler(secondMockHandler)
            ..removeHandler(mockHandler)
            ..debug('debug');

          // test mockHandler is removed only from the new logger instance
          verifyNever(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          );
          verify(
            () => secondMockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
            ),
          ).called(1);

          // secondMockHandler is not available in the first logger
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

      test(
        'should manage lazy handlers correctly',
        () async {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          final logger = EnLogger(handlers: [mockHandler])
            ..lazyDebug(() => 'hy');

          await Future<void>.delayed(Duration.zero);

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
            ..lazyCritical(() => 'error');

          await Future<void>.delayed(Duration.zero);

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
            ..lazyDebug(() => 'hy');

          await Future<void>.delayed(Duration.zero);

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
            ..lazyDebug(() => 'jo');

          await Future<void>.delayed(Duration.zero);

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
            ..lazyDebug(() => 'no write');

          await Future<void>.delayed(Duration.zero);

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
        'should lazy write with correct data',
        () async {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          final logger = EnLogger()
            ..addHandler(mockHandler)
            ..lazyDebug(
              () => 'debug',
              prefix: 'prefix',
              dataProvider: () => [],
            );

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              prefix: 'prefix',
              severity: Severity.debug,
              data: [],
            ),
          ).called(1);

          logger.lazyInfo(() => 'info');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'info',
              severity: Severity.informational,
            ),
          ).called(1);

          logger.lazyNormal(() => 'notice');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'notice',
              severity: Severity.notice,
            ),
          ).called(1);

          logger.lazyWarning(() => 'warning');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'warning',
              severity: Severity.warning,
            ),
          ).called(1);

          logger.lazyError(() => 'error');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'error',
              severity: Severity.error,
            ),
          ).called(1);

          logger.lazyCritical(() => 'critical');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'critical',
              severity: Severity.critical,
            ),
          ).called(1);

          logger.lazyAlert(() => 'alert');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'alert',
              severity: Severity.alert,
            ),
          ).called(1);

          logger.lazyEmergency(() => 'emergency');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'emergency',
              severity: Severity.emergency,
            ),
          ).called(1);
        },
      );

      test(
        'lazy message are evaluated only if needed and only once',
        () async {
          registerFallbackValue(Severity.debug);

          final mockHandler = _MockHandler();
          final secondMockHandler = _MockHandler();

          var calledCount = 0;

          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(false);

          when(
            () => secondMockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(false);

          final logger = EnLogger()
            ..addHandlers([mockHandler, secondMockHandler])
            ..lazyDebug(() {
              calledCount++;
              return 'lazy message';
            });

          await Future<void>.delayed(Duration.zero);

          expect(calledCount, 0);

          when(
            () => mockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          logger.lazyDebug(() {
            calledCount++;
            return 'lazy message';
          });

          await Future<void>.delayed(Duration.zero);

          expect(calledCount, 1);
          verify(
            () => mockHandler.write(
              'lazy message',
              severity: Severity.debug,
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              data: any(named: 'data'),
            ),
          ).called(1);
          verifyNever(
            () => secondMockHandler.write(
              'lazy message',
              severity: Severity.debug,
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              data: any(named: 'data'),
            ),
          );

          calledCount = 0;

          when(
            () => secondMockHandler.can(
              severity: any(named: 'severity'),
              prefix: any(named: 'prefix'),
            ),
          ).thenReturn(true);

          logger.lazyDebug(() {
            calledCount++;
            return 'lazy message';
          });

          await Future<void>.delayed(Duration.zero);

          expect(calledCount, 1);
          verify(
            () => mockHandler.write(
              'lazy message',
              severity: Severity.debug,
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              data: any(named: 'data'),
            ),
          );
          verify(
            () => secondMockHandler.write(
              'lazy message',
              severity: Severity.debug,
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              data: any(named: 'data'),
            ),
          ).called(1);
        },
      );

      test('should ignore errors', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger()..addHandler(mockHandler);

        Future<void> callback() async {
          logger.lazyDebug(() => throw Exception('error'));
          await Future<void>.delayed(Duration.zero);
          return Future<void>.value();
        }

        await expectLater(callback(), completion(isA<void>()));
      });
    },
  );
}
