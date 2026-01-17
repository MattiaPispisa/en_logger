import 'dart:async';

import 'package:en_logger/en_logger.dart';

/// {@template en_logger}
/// # EnLogger
///
/// ## Description
/// Entity that manages logs.
/// It contains handlers.
///
/// Each time a new log is created, the handlers are invoked to write
/// the message according to their implementation.
///
/// [PrinterHandler] is an example of a [EnLoggerHandler].
///
/// ## Example:
///
/// ```dart
/// final logger = EnLogger(
///   defaultPrefixFormat: const PrefixFormat(
///     startFormat: '[',
///     endFormat: ']',
///   ),
/// )
///   ..addHandlers([
///     PrinterHandler(),
///   ])
///   ..debug('a debug message',prefix: 'API Repository');
/// // [API_REPOSITORY] a debug message
/// ```
/// {@endtemplate}
class EnLogger {
  /// # Constructor
  /// ## Description
  /// Creates a new [EnLogger] instance.
  ///
  /// ## Parameters
  /// [handlers] - Optional list of handlers to process log messages.
  /// [handlers] can also be added later using [addHandler] or [addHandlers].
  ///
  /// [defaultPrefixFormat] - Optional default format for prefix display.
  /// This format will be applied to handlers that don't
  /// have their own prefixFormat configured.
  ///
  /// {@macro en_logger}
  EnLogger({
    List<EnLoggerHandler>? handlers,
    PrefixFormat? defaultPrefixFormat,
  })  : _handlers = handlers
                ?.map(
                  (h) =>
                      h..prefixFormat = h.prefixFormat ?? defaultPrefixFormat,
                )
                .toList() ??
            <EnLoggerHandler>[],
        _defaultPrefixFormat = defaultPrefixFormat;

  final List<EnLoggerHandler> _handlers;
  final PrefixFormat? _defaultPrefixFormat;

  /// Adds a new [handler] to process log messages.
  ///
  /// The handler's prefixFormat will be set to the logger's
  /// default prefixFormat if the handler doesn't have one configured.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger();
  /// logger.addHandler(PrinterHandler());
  /// logger.debug('message'); // PrinterHandler will write the message
  /// ```
  void addHandler(EnLoggerHandler handler) => _handlers.add(
        handler..prefixFormat = handler.prefixFormat ?? _defaultPrefixFormat,
      );

  /// Adds a list of [handlers] to process log messages.
  ///
  /// Each handler's prefixFormat will be set to the logger's
  /// default prefixFormat if the handler doesn't have one configured.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger();
  /// logger.addHandlers([
  ///   PrinterHandler(),
  ///   SentryHandler(),
  /// ]);
  /// logger.debug('message'); // PrinterHandler and SentryHandler will write the message
  /// ```
  void addHandlers(List<EnLoggerHandler> handlers) {
    handlers.forEach(addHandler);
  }

  /// Removes a [handler] from the logger.
  ///
  /// ## Example:
  /// ```dart
  /// final handler = PrinterHandler();
  /// final logger = EnLogger()..addHandler(handler);
  /// logger.removeHandler(handler);
  /// logger.debug('message'); // handler won't receive this message
  /// ```
  void removeHandler(EnLoggerHandler handler) {
    _handlers.remove(handler);
  }

  /// Removes a list of [handlers] from the logger.
  ///
  /// ## Example:
  /// ```dart
  /// final handler1 = PrinterHandler();
  /// final handler2 = PrinterHandler();
  /// final logger = EnLogger()..addHandlers([handler1, handler2]);
  /// logger.removeHandlers([handler1, handler2]);
  /// logger.debug('message'); // handlers won't receive this message
  /// ```
  void removeHandlers(List<EnLoggerHandler> handlers) {
    handlers.forEach(removeHandler);
  }

  /// Removes every handler from the logger.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger()
  ///   ..addHandler(PrinterHandler())
  ///   ..addHandler(PrinterHandler());
  /// logger.removeAllHandlers();
  /// logger.debug('message'); // no handlers will receive this message
  /// ```
  void removeAllHandlers() {
    _handlers.clear();
  }

  /// ## Description
  /// Creates a new logger instance from `this` logger with:
  ///
  /// - a pre-configured [prefix] that will be used as default for all log calls
  /// - current [EnLoggerHandler] list (a copy, so modifications to handlers
  ///   in the new instance won't affect the original logger)
  ///
  /// ## Parameters
  /// [prefix] - Optional default prefix to use for all log messages.
  ///
  /// ## Returns
  /// Returns a new [EnLogger] instance with the configured prefix and handlers.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  ///
  /// // Create a configured instance with a default prefix
  /// final apiLogger = logger.getConfiguredInstance(prefix: 'API Repository');
  /// apiLogger.debug('a debug message'); // [API_REPOSITORY] a debug message
  ///
  /// // Original logger still works without prefix
  /// logger.debug('a debug message'); // a debug message
  /// ```
  EnLogger getConfiguredInstance({String? prefix}) {
    return _EnLoggerInstance(
      prefix: prefix,
      defaultPrefixFormat: _defaultPrefixFormat?.copyWith(),
      handlers: List.of(_handlers),
    );
  }

  /// Logs a message with [Severity.emergency] level.
  ///
  /// System is unusable.
  ///
  /// Condition: A panic condition.
  ///
  /// [error] - The error message or object to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [stackTrace] - Optional stack trace associated with the error.
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.emergency(
  ///   'System failure',
  ///   stackTrace: StackTrace.current,
  ///   data: [
  ///     EnLoggerData(
  ///       name: 'system_state',
  ///       content: '{"status": "down"}',
  ///       description: 'Current system state',
  ///     ),
  ///   ],
  /// );
  /// ```
  void emergency(
    Object error, {
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: error,
        severity: Severity.emergency,
        prefix: prefix,
        stackTrace: stackTrace,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.alert] level.
  ///
  /// Action must be taken immediately.
  ///
  /// Condition: A condition that should be corrected immediately.
  ///
  /// [error] - The error message or object to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [stackTrace] - Optional stack trace associated with the error.
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.alert(
  ///   'Database connection lost',
  ///   stackTrace: StackTrace.current,
  /// );
  /// ```
  void alert(
    Object error, {
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: error,
        severity: Severity.alert,
        prefix: prefix,
        stackTrace: stackTrace,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.critical] level.
  ///
  /// Critical conditions.
  ///
  /// Condition: Hard device errors.
  ///
  /// [error] - The error message or object to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [stackTrace] - Optional stack trace associated with the error.
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.critical(
  ///   'Disk full',
  ///   stackTrace: StackTrace.current,
  /// );
  /// ```
  void critical(
    Object error, {
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: error,
        severity: Severity.critical,
        prefix: prefix,
        stackTrace: stackTrace,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.error] level.
  ///
  /// Error conditions.
  ///
  /// [error] - The error message or object to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [stackTrace] - Optional stack trace associated with the error.
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.error(
  ///   'error',
  ///   data: [
  ///     EnLoggerData(
  ///       name: 'response',
  ///       content: jsonEncode('BE data'),
  ///       description: 'serialized BE response',
  ///     ),
  ///   ],
  /// );
  /// ```
  void error(
    Object error, {
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: error,
        severity: Severity.error,
        prefix: prefix,
        stackTrace: stackTrace,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.warning] level.
  ///
  /// Warning conditions.
  ///
  /// May indicate that an error will occur if action is not taken.
  ///
  /// [message] - The message to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.warning('Low disk space');
  /// ```
  void warning(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: message,
        severity: Severity.warning,
        prefix: prefix,
        stackTrace: null,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.notice] level.
  ///
  /// Normal but significant conditions.
  ///
  /// Condition: Conditions that are not error conditions,
  /// but that may require special handling.
  ///
  /// [message] - The message to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.normal('User logged in');
  /// ```
  void normal(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: message,
        severity: Severity.notice,
        prefix: prefix,
        stackTrace: null,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.informational] level.
  ///
  /// Informational messages.
  ///
  /// Condition: Confirmation that the program is working as expected.
  ///
  /// [message] - The message to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.info('Application started');
  /// ```
  void info(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: message,
        severity: Severity.informational,
        prefix: prefix,
        stackTrace: null,
        data: data,
      ),
    );
  }

  /// Logs a message with [Severity.debug] level.
  ///
  /// Debug-level messages.
  ///
  /// Condition: Messages that contain information
  /// normally of use only when debugging a program.
  ///
  /// [message] - The message to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  ///
  /// Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(PrinterHandler());
  /// logger.debug('a debug message');
  ///
  /// // With prefix
  /// logger.debug('a debug message', prefix: 'Custom prefix');
  /// ```
  void debug(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
  }) {
    _log(
      _EnLogDataDto(
        message: message,
        severity: Severity.debug,
        prefix: prefix,
        stackTrace: null,
        data: data,
      ),
    );
  }

  void _log(_EnLogDataDto data) {
    _asyncWrite(data);
    return;
  }

  // The write operations of the handlers are managed in a
  // separate task since attachments with unknown sizes might be present.
  Future<void> _asyncWrite(_EnLogDataDto data) async {
    final tasks = <Future<void>>[];

    for (final handler in _handlers) {
      FutureOr<void> futureOrWrite() async => handler.write(
            data.message.toString(),
            severity: data.severity,
            prefix: data.prefix,
            data: data.data,
            stackTrace: data.stackTrace,
          );
      tasks.add(Future.sync(futureOrWrite));
    }

    await Future.wait(tasks);
    return;
  }
}

/// A pre-configured instance of the logger.
class _EnLoggerInstance extends EnLogger {
  _EnLoggerInstance({
    this.prefix,
    super.handlers,
    super.defaultPrefixFormat,
  });

  final String? prefix;

  @override
  void _log(_EnLogDataDto data) {
    _asyncWrite(
      _EnLogDataDto(
        data: data.data,
        message: data.message,
        // set default prefix
        prefix: prefix ?? data.prefix,
        severity: data.severity,
        stackTrace: data.stackTrace,
      ),
    );
    return;
  }
}

class _EnLogDataDto {
  const _EnLogDataDto({
    required this.message,
    required this.severity,
    required this.prefix,
    required this.stackTrace,
    required this.data,
  });

  final Object message;
  final Severity severity;
  final String? prefix;
  final StackTrace? stackTrace;
  final List<EnLoggerData>? data;
}
