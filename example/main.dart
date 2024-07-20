import 'dart:convert';

import 'package:en_logger/en_logger.dart';
import 'package:sentry/sentry.dart';

void main(List<String> args) async {
  // a custom handler that under the hood use sentry
  final sentry = await SentryHandler.init();

  // default printer configured
  final printer = PrinterHandler()
    ..configure({Severity.notice: PrinterColor.green()});

  // an enLogger with a default prefix format
  final logger = EnLogger(
      defaultPrefixFormat: PrefixFormat(
    startFormat: '[',
    endFormat: ']',
    style: PrefixStyle.uppercaseSnakeCase,
  ))
    ..addHandlers([
      sentry,
      printer,
    ]);

  // debug log
  logger.debug('a debug message');

  // error with data
  logger.error(
    "error",
    data: [
      EnLoggerData(
        name: "response",
        content: jsonEncode("BE data"),
        description: "serialized BE response",
      ),
    ],
  );

  // logger instance with prefix
  final instLogger = logger.getConfiguredInstance(prefix: 'API Repository');
  instLogger.debug('a debug message'); // [API Repository] a debug message
  instLogger.error(
    'error',
    prefix: 'Custom prefix',
  ); // [Custom prefix] a debug message
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
