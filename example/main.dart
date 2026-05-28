// ignore_for_file: avoid_print just for the example

import 'dart:async';
import 'dart:convert';

import 'package:en_logger/en_logger.dart';
import 'package:sentry/sentry.dart';

void main(List<String> args) async {
  // a custom handler that under the hood use sentry
  final sentry = await SentryHandler.init();

  // default printer configured
  final printer = PrinterHandler()
    ..configure({
      Severity.notice: const PrinterColor.green(),
    });

  // an enLogger with a default prefix format
  final logger = EnLogger(
    zoneContextKeys: {#userId},
    defaultPrefixFormat: const PrefixFormat(
      startFormat: '[',
      endFormat: ']',
    ),
  )
    ..addHandlers([
      sentry,
      printer,
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
