import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockHandler extends Mock implements EnLoggerHandler {}

class _User {
  _User(this.id);

  final String id;

  @override
  String toString() => 'User(id: $id)';
}

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
    required DateTime timestamp,
    required String eventId,
    required Map<String, dynamic> tags,
    required int sequenceNumber,
    String? prefix,
    Object? error,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
    String? isolateName,
    String? callerInfo,
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

      test('should "can" be default true', () async {
        final handler = _NoOpEnHandler();
        EnLogger()
          ..addHandler(handler)
          ..debug('debug');

        await Future<void>.delayed(Duration.zero);

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

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'hy',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              data: any(named: 'data'),
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger
            ..removeHandler(mockHandler)
            ..critical('error');

          await Future<void>.delayed(Duration.zero);

          verifyNever(
            () => mockHandler.write(
              'error',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.critical,
              data: any(named: 'data'),
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          );

          logger
            ..addHandler(mockHandler)
            ..removeAllHandlers()
            ..debug('hy');

          await Future<void>.delayed(Duration.zero);

          verifyNever(
            () => mockHandler.write(
              'hy',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: any(named: 'severity'),
              data: any(named: 'data'),
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          );

          logger
            ..addHandlers([mockHandler])
            ..debug('jo');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'jo',
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              data: any(named: 'data'),
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          await Future<void>.delayed(Duration.zero);

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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          );
        },
      );

      test('should toString() message only once', () async {
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

        await Future<void>.delayed(Duration.zero);

        expect(mockObject.toStringCalledCount, 1);
        verify(
          () => mockHandler.write(
            any(),
            severity: Severity.debug,
            prefix: any(named: 'prefix'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        ).called(1);
      });

      test(
        'should write with correct data',
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
            ..debug(
              'debug',
              prefix: 'prefix',
              data: [],
            );
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              prefix: 'prefix',
              severity: Severity.debug,
              data: [],
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.info('info');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'info',
              severity: Severity.informational,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.normal('notice');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'notice',
              severity: Severity.notice,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.warning('warning');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'warning',
              severity: Severity.warning,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.error(
            'error',
            error: Exception('error'),
          );
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'error',
              severity: Severity.error,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: isA<Exception>().having(
                (e) => e.toString(),
                'toString',
                contains('error'),
              ),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.critical('critical');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'critical',
              severity: Severity.critical,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.alert('alert');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'alert',
              severity: Severity.alert,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.emergency('emergency');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'emergency',
              severity: Severity.emergency,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);
        },
      );

      test(
        'should handle EnLoggerData',
        () async {
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
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              severity: Severity.debug,
              data: data,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);
        },
      );

      test(
        'should handle EnLogger instances correctly',
        () async {
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
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          // no prefix is passed and there isn't a default one
          logger.debug('debug');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);
        },
      );

      test(
        'should handle EnLogger instances correctly'
        ' even without prefix override',
        () async {
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
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          // no prefix is passed and there isn't a default one
          logger.debug('debug');
          await Future<void>.delayed(Duration.zero);

          verifyNever(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          );
        },
      );

      test(
        'should handle EnLogger instances correctly',
        () async {
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
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);
          verify(
            () => secondMockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          // secondMockHandler is not available in the first logger
          logger.debug('debug');
          await Future<void>.delayed(Duration.zero);

          verifyNever(
            () => secondMockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          );
        },
      );

      test('should handle nested instances correctly', () async {
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
        await Future<void>.delayed(Duration.zero);

        verify(
          () => mockHandler.write(
            'debug',
            stackTrace: any(named: 'stackTrace'),
            severity: Severity.debug,
            prefix: 'prefix',
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        ).called(1);
        verify(
          () => mockHandler.write(
            'debug2',
            stackTrace: any(named: 'stackTrace'),
            severity: Severity.debug,
            prefix: 'prefix2',
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        ).called(1);
      });

      test(
        'should handle EnLogger instances correctly',
        () async {
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

          await Future<void>.delayed(Duration.zero);

          // test mockHandler is removed only from the new logger instance
          verifyNever(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          );
          verify(
            () => secondMockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              prefix: 'prefix',
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          // secondMockHandler is not available in the first logger
          logger.debug('debug');
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'debug',
              stackTrace: any(named: 'stackTrace'),
              severity: Severity.debug,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyInfo(() => 'info');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'info',
              severity: Severity.informational,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyNormal(() => 'notice');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'notice',
              severity: Severity.notice,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyWarning(() => 'warning');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'warning',
              severity: Severity.warning,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyError(() => 'error');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'error',
              severity: Severity.error,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyCritical(() => 'critical');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'critical',
              severity: Severity.critical,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyAlert(() => 'alert');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'alert',
              severity: Severity.alert,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);

          logger.lazyEmergency(() => 'emergency');

          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockHandler.write(
              'emergency',
              severity: Severity.emergency,
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
            ),
          ).called(1);
          verifyNever(
            () => secondMockHandler.write(
              'lazy message',
              severity: Severity.debug,
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              data: any(named: 'data'),
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
            () => secondMockHandler.write(
              'lazy message',
              severity: Severity.debug,
              prefix: any(named: 'prefix'),
              stackTrace: any(named: 'stackTrace'),
              data: any(named: 'data'),
              timestamp: any(named: 'timestamp'),
              eventId: any(named: 'eventId'),
              sequenceNumber: any(named: 'sequenceNumber'),
              tags: any(named: 'tags'),
              error: any(named: 'error'),
              callerInfo: any(named: 'callerInfo'),
              isolateName: any(named: 'isolateName'),
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
          logger.lazyDebug(() async {
            await Future<void>.delayed(Duration.zero);
            throw Exception('error');
          });
          await Future<void>.delayed(Duration.zero);
          return Future<void>.value();
        }

        await expectLater(callback(), completion(isA<void>()));
      });

      test('close should ignore new logs', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger()..addHandler(mockHandler);

        await logger.close();

        logger
          ..debug('should be ignored')
          ..lazyDebug(() => 'should be ignored');

        await Future<void>.delayed(Duration.zero);

        verifyNever(
          () => mockHandler.write(
            any(),
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        );
      });

      test('close should await pending lazy evaluations', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger()..addHandler(mockHandler);

        final completer = Completer<String>();

        // Start a lazy log that is delayed by the completer
        logger.lazyDebug(() => completer.future);

        final closeFuture = logger.close();

        // Ensure close is pending
        var isCloseCompleted = false;
        closeFuture.whenComplete(() => isCloseCompleted = true).ignore();

        await Future<void>.delayed(Duration.zero);
        expect(isCloseCompleted, isFalse);

        // Complete the lazy evaluation
        completer.complete('delayed log');

        // Now await the close
        await closeFuture;

        expect(isCloseCompleted, isTrue);

        verify(
          () => mockHandler.write(
            'delayed log',
            severity: Severity.debug,
            prefix: any(named: 'prefix'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        ).called(1);
      });

      test('close should cascade to configured instances', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger()..addHandler(mockHandler);
        final childLogger = logger.getConfiguredInstance(prefix: 'child');

        await logger.close();

        // The child logger should also be disposed and ignore new logs
        childLogger.debug('should be ignored by child');

        await Future<void>.delayed(Duration.zero);

        verifyNever(
          () => mockHandler.write(
            any(),
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        );

        expect(childLogger.closed, isTrue);
      });

      test('dispose should work synchronously and initiate closing', () async {
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
          ..dispose();

        expect(logger.closed, isTrue);

        logger.debug('should be ignored');

        await Future<void>.delayed(Duration.zero);

        verifyNever(
          () => mockHandler.write(
            any(),
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
            stackTrace: any(named: 'stackTrace'),
            data: any(named: 'data'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        );
      });

      test(
          'multiple calls to close and dispose should do nothing and not throw',
          () async {
        final logger = EnLogger();

        expect(logger.dispose, returnsNormally);
        expect(logger.closed, isTrue);

        expect(logger.dispose, returnsNormally);

        await expectLater(logger.close(), completes);
        await expectLater(logger.close(), completes);

        expect(logger.closed, isTrue);
      });

      test(
          'close should complete even if a lazy evaluation throws an exception',
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
          ..lazyDebug(() async {
            await Future<void>.delayed(Duration.zero);
            throw Exception('Simulated lazy evaluation error');
          });

        await expectLater(logger.close(), completion(isA<void>()));

        expect(logger.closed, isTrue);
      });

      test('should preserve logs order (fifo)', () async {
        registerFallbackValue(Severity.debug);

        final firstLogCompleter = Completer<void>();
        final secondLogCompleter = Completer<void>();

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        EnLogger()
          ..addHandler(mockHandler)
          ..lazyDebug(
            () async {
              await firstLogCompleter.future;
              return 'debug';
            },
            prefix: 'prefix',
            dataProvider: () => [],
          )
          ..lazyInfo(() async {
            await secondLogCompleter.future;
            return 'info';
          });

        await Future<void>.delayed(Duration.zero);

        secondLogCompleter.complete();

        await Future<void>.delayed(Duration.zero);

        firstLogCompleter.complete();

        await Future<void>.delayed(Duration.zero);

        final verifications = verifyInOrder([
          () => mockHandler.write(
                'debug',
                prefix: any(named: 'prefix'),
                severity: any(named: 'severity'),
                stackTrace: any(named: 'stackTrace'),
                timestamp: captureAny(named: 'timestamp'),
                eventId: any(named: 'eventId'),
                sequenceNumber: captureAny(named: 'sequenceNumber'),
                tags: any(named: 'tags'),
                data: any(named: 'data'),
                error: any(named: 'error'),
                callerInfo: any(named: 'callerInfo'),
                isolateName: any(named: 'isolateName'),
              ),
          () => mockHandler.write(
                'info',
                prefix: any(named: 'prefix'),
                severity: any(named: 'severity'),
                stackTrace: any(named: 'stackTrace'),
                timestamp: captureAny(named: 'timestamp'),
                eventId: any(named: 'eventId'),
                sequenceNumber: captureAny(named: 'sequenceNumber'),
                tags: any(named: 'tags'),
                data: any(named: 'data'),
                error: any(named: 'error'),
                callerInfo: any(named: 'callerInfo'),
                isolateName: any(named: 'isolateName'),
              ),
        ]);

        verifyNever(
          () => mockHandler.write(
            any(),
            prefix: any(named: 'prefix'),
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        );

        final firstTimestamp = verifications[0].captured.first as DateTime;
        final secondTimestamp = verifications[1].captured.first as DateTime;
        expect(firstTimestamp.compareTo(secondTimestamp) <= 0, isTrue);

        final firstSequenceNumber = verifications[0].captured[1] as int;
        final secondSequenceNumber = verifications[1].captured[1] as int;
        expect(firstSequenceNumber < secondSequenceNumber, isTrue);
      });

      test('should extract zoneContextKeys and pass them as tags', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger(
          zoneContextKeys: {#userId, 'tenant_id'},
        )..addHandler(mockHandler);

        runZoned(
          () {
            logger.debug(
              'test message',
              tags: {
                'custom_tag': 'custom_value',
              },
            );
          },
          zoneValues: {
            #userId: 'user_123',
            'tenant_id': 42,
            #ignoredKey: 'ignoredKey',
          },
        );

        await Future<void>.delayed(Duration.zero);

        final verification = verify(
          () => mockHandler.write(
            'test message',
            prefix: any(named: 'prefix'),
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: captureAny(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        )..called(1);

        final capturedTags =
            verification.captured.first as Map<String, dynamic>;

        expect(capturedTags, isA<Map<String, dynamic>>());
        expect(capturedTags.length, equals(3));

        expect(capturedTags['userId'], equals('user_123'));
        expect(capturedTags['tenant_id'], equals(42));
        expect(capturedTags['custom_tag'], equals('custom_value'));
        expect(capturedTags.containsKey('ignoredKey'), isFalse);
      });

      test('should method tags override zone context tags', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger(
          zoneContextKeys: {#userId, 'tenant_id'},
        )..addHandler(mockHandler);

        runZoned(
          () {
            logger.debug(
              'test message',
              tags: {
                'userId': 'user_123_override',
              },
            );
          },
          zoneValues: {
            #userId: 'user_123',
          },
        );

        await Future<void>.delayed(Duration.zero);

        final verification = verify(
          () => mockHandler.write(
            'test message',
            prefix: any(named: 'prefix'),
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: captureAny(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        )..called(1);

        final capturedTags =
            verification.captured.first as Map<String, dynamic>;

        expect(capturedTags, isA<Map<String, dynamic>>());
        expect(capturedTags['userId'], equals('user_123_override'));
      });

      test('should sanitize tags', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger(
          zoneContextKeys: {#userId, #tenant_id},
        )..addHandler(mockHandler);

        runZoned(
          () {
            logger.debug('test message');
          },
          zoneValues: {
            #userId: _User('user_123'),
            #tenant_id: [_User('tenant_42'), 12, true],
          },
        );

        await Future<void>.delayed(Duration.zero);

        final verification = verify(
          () => mockHandler.write(
            'test message',
            prefix: any(named: 'prefix'),
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: captureAny(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        )..called(1);

        final capturedTags =
            verification.captured.first as Map<String, dynamic>;

        expect(capturedTags, isA<Map<String, dynamic>>());
        expect(capturedTags['userId'], equals('User(id: user_123)'));
        expect(
          capturedTags['tenant_id'],
          equals(
            ['User(id: tenant_42)', 12, true],
          ),
        );
      });

      test('should merge zone context keys in child instances', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        final logger = EnLogger(
          zoneContextKeys: {#userId},
        )..addHandler(mockHandler);

        final childLogger = logger.getConfiguredInstance(
          prefix: 'child',
          zoneContextKeys: {#tenant_id},
        );

        runZoned(
          () {
            childLogger.debug(
              'test message',
              tags: {
                'custom_tag': 'custom_value',
              },
            );
          },
          zoneValues: {
            #userId: 'user_123',
            #tenant_id: 42,
          },
        );

        await Future<void>.delayed(Duration.zero);
        final verification = verify(
          () => mockHandler.write(
            'test message',
            prefix: 'child',
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: captureAny(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: any(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        )..called(1);

        final capturedTags =
            verification.captured.first as Map<String, dynamic>;
        expect(capturedTags, isA<Map<String, dynamic>>());
        expect(capturedTags.length, equals(3));
        expect(capturedTags['userId'], equals('user_123'));
        expect(capturedTags['tenant_id'], equals(42));
        expect(capturedTags['custom_tag'], equals('custom_value'));
      });

      test('should callerInfo match the exact line of execution', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        final completer = Completer<void>();

        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        EnLogger(includeCallerInfo: true)
          ..addHandler(mockHandler)
          ..lazyDebug(() async {
            await completer.future;
            return 'lazyDebug';
          });

        await Future<void>.delayed(Duration.zero);
        completer.complete();
        await Future<void>.delayed(Duration.zero);

        final verification = verify(
          () => mockHandler.write(
            'lazyDebug',
            prefix: any(named: 'prefix'),
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: captureAny(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        )..called(1);

        final callerInfo = verification.captured.first;
        expect(
          callerInfo,
          contains(
            'en_logger/test/src/logger_test.dart:1791',
          ),
        );
      });

      test('should callerInfo be null if disabled', () async {
        registerFallbackValue(Severity.debug);

        final mockHandler = _MockHandler();
        final completer = Completer<void>();

        when(
          () => mockHandler.can(
            severity: any(named: 'severity'),
            prefix: any(named: 'prefix'),
          ),
        ).thenReturn(true);

        EnLogger(includeCallerInfo: false)
          ..addHandler(mockHandler)
          ..lazyDebug(() async {
            await completer.future;
            return 'lazyDebug';
          });

        await Future<void>.delayed(Duration.zero);
        completer.complete();
        await Future<void>.delayed(Duration.zero);

        final verification = verify(
          () => mockHandler.write(
            'lazyDebug',
            prefix: any(named: 'prefix'),
            severity: any(named: 'severity'),
            stackTrace: any(named: 'stackTrace'),
            timestamp: any(named: 'timestamp'),
            eventId: any(named: 'eventId'),
            sequenceNumber: any(named: 'sequenceNumber'),
            tags: any(named: 'tags'),
            data: any(named: 'data'),
            error: any(named: 'error'),
            callerInfo: captureAny(named: 'callerInfo'),
            isolateName: any(named: 'isolateName'),
          ),
        )..called(1);

        final callerInfo = verification.captured.first;
        expect(callerInfo, isNull);
      });
    },
  );
}
