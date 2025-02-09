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

  // logger instance with prefix
  logger.getConfiguredInstance(prefix: 'API Repository')

    // [API Repository] a debug message
    ..debug('a debug message')

    // [Custom prefix] a debug message
    ..error(
      'error',
      prefix: 'Custom prefix',
    );
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
    String? prefix,
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
