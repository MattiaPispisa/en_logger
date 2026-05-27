import 'dart:isolate';

import 'package:en_logger/en_logger.dart';

/// {@template en_logger_helper_extension}
/// Helper extension for [EnLogger].
/// {@endtemplate}
extension EnLoggerHelper on EnLogger {
  /// listen to all uncaught exceptions of the Dart Isolate automatically
  /// and log them as critical errors.
  void listenToUncaughtErrors() {
    Isolate.current.addErrorListener(
      RawReceivePort((dynamic pair) {
        if (pair is! List || pair.length != 2) {
          return;
        }
        critical(
          'Uncaught Isolate Error',
          error: pair.first,
          stackTrace: pair.last as StackTrace,
        );
      }).sendPort,
    );
  }
}
