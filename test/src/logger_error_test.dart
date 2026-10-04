import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _RecordingHandler extends EnLoggerHandler {
  final List<String> messages = [];

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
    messages.add(message);
  }
}

/// Throws synchronously when the message is `boom`.
class _FailingHandler extends EnLoggerHandler {
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
    if (message == 'boom') {
      throw StateError('sink down');
    }
  }
}

/// Completes with an error when the message is `boom`
/// (e.g. a remote handler failing a network call).
class _AsyncFailingHandler extends EnLoggerHandler {
  @override
  Future<void> write(
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
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (message == 'boom') {
      throw StateError('async sink down');
    }
  }
}

class _ThrowingCanHandler extends _RecordingHandler {
  @override
  bool can({required Severity severity, String? prefix}) {
    throw StateError('can failed');
  }
}

class _ReportedError {
  _ReportedError(this.error, this.handler);

  final Object error;
  final EnLoggerHandler? handler;
}

void main() {
  group('EnLogger error isolation', () {
    late List<_ReportedError> reported;

    void onError(Object error, StackTrace stackTrace, EnLoggerHandler? h) {
      reported.add(_ReportedError(error, h));
    }

    setUp(() {
      reported = [];
    });

    test(
      'a handler throwing synchronously does not stop '
      'other handlers nor following logs',
      () async {
        final recording = _RecordingHandler();
        final failing = _FailingHandler();
        final logger = EnLogger(onError: onError)
          ..addHandlers([failing, recording])
          ..info('one')
          ..info('boom')
          ..info('three');

        await logger.close();

        expect(recording.messages, ['one', 'boom', 'three']);
        expect(reported, hasLength(1));
        expect(reported.single.error, isA<StateError>());
        expect(reported.single.handler, same(failing));
      },
    );

    test(
      'a handler failing asynchronously does not stop following logs',
      () async {
        final recording = _RecordingHandler();
        final failing = _AsyncFailingHandler();
        final logger = EnLogger(onError: onError)
          ..addHandlers([failing, recording])
          ..info('one')
          ..info('boom')
          ..info('three');

        await logger.close();

        expect(recording.messages, ['one', 'boom', 'three']);
        expect(reported.single.error, isA<StateError>());
        expect(reported.single.handler, same(failing));
      },
    );

    test('a throwing lazy message does not stop following logs', () async {
      final recording = _RecordingHandler();
      final logger = EnLogger(onError: onError)
        ..addHandler(recording)
        ..lazyInfo(() => throw StateError('lazy failed'))
        ..lazyInfo(() async {
          await Future<void>.delayed(Duration.zero);
          throw StateError('async lazy failed');
        })
        ..info('after lazy');

      await logger.close();

      expect(recording.messages, ['after lazy']);
      expect(reported, hasLength(2));
      expect(reported.every((r) => r.handler == null), isTrue);
    });

    test('a throwing lazy data provider does not stop following logs',
        () async {
      final recording = _RecordingHandler();
      final logger = EnLogger(onError: onError)
        ..addHandler(recording)
        ..lazyInfo(
          () => 'skipped',
          dataProvider: () => throw StateError('data failed'),
        )
        ..info('after lazy data');

      await logger.close();

      expect(recording.messages, ['after lazy data']);
      expect(reported.single.handler, isNull);
    });

    test('a throwing can skips only that handler', () async {
      final recording = _RecordingHandler();
      final throwingCan = _ThrowingCanHandler();
      final logger = EnLogger(onError: onError)
        ..addHandlers([throwingCan, recording]);

      expect(() => logger.info('one'), returnsNormally);
      await logger.close();

      expect(recording.messages, ['one']);
      expect(throwingCan.messages, isEmpty);
      expect(reported.single.handler, same(throwingCan));
    });

    test('a throwing onError does not break the logger', () async {
      final recording = _RecordingHandler();
      final logger = EnLogger(
        onError: (_, __, ___) => throw StateError('onError failed'),
      )
        ..addHandlers([_FailingHandler(), recording])
        ..info('boom')
        ..info('after');

      await logger.close();

      expect(recording.messages, ['boom', 'after']);
    });

    test('errors are ignored when onError is not provided', () async {
      final recording = _RecordingHandler();
      final logger = EnLogger()
        ..addHandlers([_FailingHandler(), recording])
        ..info('boom')
        ..info('after');

      await logger.close();

      expect(recording.messages, ['boom', 'after']);
    });

    test('configured instances share onError and the log chain', () async {
      final recording = _RecordingHandler();
      final failing = _FailingHandler();
      final logger = EnLogger(onError: onError)
        ..addHandlers([failing, recording]);

      logger.getConfiguredInstance(prefix: 'child').info('boom');
      logger.info('after');

      await logger.close();

      expect(recording.messages, ['boom', 'after']);
      expect(reported.single.handler, same(failing));
    });
  });
}
