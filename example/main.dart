// ignore_for_file: avoid_print just for example

import 'dart:async';
import 'dart:convert';

import 'package:en_logger/en_logger.dart';
import 'package:sentry/sentry.dart';

void main(List<String> args) async {
  // a custom handler that under the hood use sentry
  // final sentry = await SentryHandler.init();

  // default handler configured
  final devLogHandler = DevLogHandler()
    ..configure({
      Severity.notice: const DevLogColor.green(),
    });

  // an enLogger with a default prefix format
  final logger = EnLogger(
    zoneContextKeys: {#userId},
    includeCallerInfo: true,
    defaultPrefixFormat: const PrefixFormat(
      startFormat: '[',
      endFormat: ']',
    ),
  )
    ..addHandlers([
      // sentry,
      VerbosePrintHandler(),
      devLogHandler,
    ])

    // debug log
    ..debug('a debug message')

    // error with data
    ..error(
      'error',
      data: [
        EnLoggerData(
          name: 'response',
          content: jsonEncode('BE data'),
          description: 'serialized BE response',
        ),
      ],
    );

  runZoned(
    () {
      // In addition to the method tags, the zoneContextKeys
      // values will be extracted from the zones

      // logger instance with prefix
      logger.getConfiguredInstance(prefix: 'API Repository')

        // [API Repository] a debug message
        ..debug('a debug message')

        // [Custom prefix] a debug message
        ..error(
          'error',
          prefix: 'Custom prefix',
        );
    },
    zoneValues: {#userId: '123'},
  );

  // Lazy: closure is only run if at least one handler will write
  // (e.g. can(severity) is true)
  logger
    ..lazyDebug(() => 'expensive debug message')
    ..lazyError(() => 'error from sync computation')
    // lazy callback can be asynchronous
    ..lazyInfo(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 'heavy computation';
    });

  // close the logger
  // wait for all pending logs to be written before closing the logger
  await logger.close();

  // logger is closed, so this message won't be written
  logger.debug('a debug message');

  print(logger.closed); // true
}

class SentryHandler extends EnLoggerHandler {
  SentryHandler._();

  static Future<SentryHandler> init() async {
    await Sentry.init(
      (options) {
        options.dsn = 'https://example@sentry.io/example';
      },
    );
    return SentryHandler._();
  }

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
    // just a simple example
    // fine tune your implementation...
    if (severity.atLeastError) {
      Sentry.captureException(message, stackTrace: stackTrace);
      return;
    }
    Sentry.captureMessage(message);
  }
}

class VerbosePrintHandler extends EnLoggerHandler {
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
    var content = message;
    if (prefix != null && prefixFormat != null) {
      content = '${prefixFormat!.format(prefix)} $content';
    }
    final encoded = const JsonEncoder.withIndent('  ').convert({
      'content': content,
      'severity': severity.level,
      'eventId': eventId,
      'sequenceNumber': sequenceNumber,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
      'callerInfo': callerInfo ?? '-',
      'isolateName': isolateName,
    });
    return print(encoded);
  }
}
