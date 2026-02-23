import 'dart:async';

import 'package:en_logger/en_logger.dart';

/// An async closure that returns a value of type [T].
/// Used for lazy evaluation in [EnLogger] "lazy" methods.
typedef EnLoggerLazyProvider<T> = FutureOr<T> Function();

/// [EnLoggerLazyMessageProvider] for [Object].
typedef EnLoggerLazyMessageProvider = EnLoggerLazyProvider<Object>;

/// [EnLoggerLazyDataProvider] for [EnLoggerData].
typedef EnLoggerLazyDataProvider = EnLoggerLazyProvider<List<EnLoggerData>>;

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
///   ..debug('a debug message',prefix: 'API Repository')
/// // [API_REPOSITORY] a debug message
///   ..lazyDebug(() => 'a lazy debug message', prefix: 'API Repository');
/// // [API_REPOSITORY] a lazy debug message 
/// // evaluated only when at least one handler will write (can returns true)
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

  /// {@template en_logger_emergency}
  /// ## Description
  /// Logs a message with [Severity.emergency] level.
  ///
  /// System is unusable.
  ///
  /// Condition: A panic condition.
  /// {@endtemplate}
  ///
  /// {@template en_logger_error_parameters}
  /// ## Parameters
  /// [error] - The error message or object to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [stackTrace] - Optional stack trace associated with the error.
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  /// {@endtemplate}
  ///
  /// ## Example
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

  /// {@template en_logger_alert}
  /// ## Description
  /// Logs a message with [Severity.alert] level.
  ///
  /// Action must be taken immediately.
  ///
  /// Condition: A condition that should be corrected immediately.
  /// {@endtemplate}
  ///
  /// {@macro en_logger_error_parameters}
  ///
  /// ## Example
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

  /// {@template en_logger_critical}
  /// ## Description
  /// Logs a message with [Severity.critical] level.
  ///
  /// Critical conditions.
  ///
  /// Condition: Hard device errors.
  /// {@endtemplate}
  ///
  /// {@macro en_logger_error_parameters}
  ///
  /// ## Example
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

  /// {@template en_logger_error}
  /// ## Description
  /// Logs a message with [Severity.error] level.
  ///
  /// Error conditions.
  /// {@endtemplate}
  ///
  /// {@macro en_logger_error_parameters}
  ///
  /// ## Example
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

  /// {@template en_logger_warning}
  /// ## Description
  /// Logs a message with [Severity.warning] level.
  ///
  /// Warning conditions.
  ///
  /// May indicate that an error will occur if action is not taken.
  /// {@endtemplate}
  ///
  /// {@template en_logger_message_parameters}
  /// ## Parameters
  /// [message] - The message to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  /// {@endtemplate}
  ///
  /// ## Example
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

  /// {@template en_logger_notice}
  /// ## Description
  /// Logs a message with [Severity.notice] level.
  ///
  /// Normal but significant conditions.
  ///
  /// Condition: Conditions that are not error conditions,
  /// but that may require special handling.
  /// {@endtemplate}
  ///
  /// {@macro en_logger_message_parameters}
  ///
  /// ## Example
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

  /// {@template en_logger_informational}
  /// ## Description
  /// Logs a message with [Severity.informational] level.
  ///
  /// Informational messages.
  ///
  /// Condition: Confirmation that the program is working as expected.
  /// {@endtemplate}
  ///
  /// {@macro en_logger_message_parameters}
  ///
  /// ## Example
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

  /// {@template en_logger_debug}
  /// ## Description
  /// Logs a message with [Severity.debug] level.
  ///
  /// Debug-level messages.
  ///
  /// Condition: Messages that contain information
  /// normally of use only when debugging a program.
  /// {@endtemplate}
  ///
  /// {@macro en_logger_message_parameters}
  ///
  /// ## Example
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

  /// {@macro en_logger_emergency}
  ///
  /// {@template en_logger_lazy_variant}
  /// ## Lazy variant
  /// Lazy version: [messageProvider] is called only when at least one handler
  /// actually writes, so expensive computations are skipped when the log
  /// level is disabled.
  /// {@endtemplate}
  ///
  /// {@template en_logger_lazy_error_parameters}
  /// ## Parameters
  /// [messageProvider] - Closure that returns the message. Called only when
  /// at least one handler will write.
  ///
  /// [prefix] - Optional prefix for this log message.
  ///
  /// [stackTrace] - Optional stack trace associated with the log message.
  ///
  /// [dataProvider] - Optional closure that returns the list of additional
  /// data to attach to the log message. Called only when at least one handler
  /// will write.
  /// {@endtemplate}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyEmergency(() => fibonacci(20));
  /// // fibonacci(20) not called if emergency is disabled (handler's `can` returns `false`)
  /// ```
  void lazyEmergency(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.emergency,
        prefix: prefix,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_alert}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@macro en_logger_lazy_error_parameters}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyAlert(() => fibonacci(20));
  /// // fibonacci(20) not called if alert is disabled (handler's `can` returns `false`)
  /// ```
  void lazyAlert(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.alert,
        prefix: prefix,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_critical}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@macro en_logger_lazy_error_parameters}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyCritical(() => fibonacci(20));
  /// // fibonacci(20) not called if critical is disabled (handler's `can` returns `false`)
  /// ```
  void lazyCritical(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.critical,
        prefix: prefix,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_error}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@macro en_logger_lazy_error_parameters}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyError(() => fibonacci(20));
  /// // fibonacci(20) not called if error is disabled (handler's `can` returns `false`)
  /// ```
  void lazyError(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.error,
        prefix: prefix,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_warning}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@template en_logger_lazy_message_parameters}
  /// ## Parameters
  /// [messageProvider] - Closure that returns the message. Called only when
  /// at least one handler will write.
  ///
  /// [prefix] - Optional prefix for this log message.
  ///
  /// [dataProvider] - Optional closure that returns the list of additional
  /// data to attach to the log message. Called only when at least one handler
  /// will write.
  /// {@endtemplate}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyWarning(() => fibonacci(20));
  /// // fibonacci(20) not called if warning is disabled (handler's `can` returns `false`)
  /// ```
  void lazyWarning(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.warning,
        prefix: prefix,
        stackTrace: null,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_notice}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@macro en_logger_lazy_message_parameters}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyNormal(() => fibonacci(20));
  /// // fibonacci(20) not called if normal is disabled (handler's `can` returns `false`)
  /// ```
  void lazyNormal(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.notice,
        prefix: prefix,
        stackTrace: null,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_informational}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@macro en_logger_lazy_message_parameters}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyInfo(() => fibonacci(20));
  /// // fibonacci(20) not called if info is disabled (handler's `can` returns `false`)
  /// ```
  void lazyInfo(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.informational,
        prefix: prefix,
        stackTrace: null,
        dataProvider: dataProvider,
      ),
    );
  }

  /// {@macro en_logger_debug}
  ///
  /// {@macro en_logger_lazy_variant}
  ///
  /// {@macro en_logger_lazy_message_parameters}
  ///
  /// ## Example
  /// ```dart
  /// logger.lazyDebug(() => fibonacci(20)); // fibonacci(20) not called if debug is disabled
  /// ```
  void lazyDebug(
    EnLoggerLazyMessageProvider messageProvider, {
    String? prefix,
    EnLoggerLazyDataProvider? dataProvider,
  }) {
    _log(
      _EnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.debug,
        prefix: prefix,
        stackTrace: null,
        dataProvider: dataProvider,
      ),
    );
  }

  void _log(_EnLogDataDto data) {
    _asyncWrite(data).ignore();
    return;
  }

  // The write operations of the handlers are managed in a
  // separate task since attachments with unknown sizes might be present.
  Future<void> _asyncWrite(_EnLogDataDto data) async {
    if (_handlers.isEmpty) {
      return;
    }

    final handlersToWrite = _handlers.where(
      (h) => h.can(
        severity: data.severity,
        prefix: data.prefix,
      ),
    );

    if (handlersToWrite.isEmpty) {
      return;
    }

    final resolvedMessage = data.lazyMessage != null
        ? (await data.lazyMessage!()).toString()
        : data.message.toString();

    final resolvedData =
        data.dataProvider != null ? await data.dataProvider!() : data.data;

    final tasks = <Future<void>>[];

    for (final handler in handlersToWrite) {
      FutureOr<void> futureOrWrite() async => handler.write(
            resolvedMessage,
            severity: data.severity,
            prefix: data.prefix,
            data: resolvedData,
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
        lazyMessage: data.lazyMessage,
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
    required this.severity,
    required this.prefix,
    required this.stackTrace,
    this.data,
    this.dataProvider,
    this.message,
    this.lazyMessage,
  }) : assert(
          (message != null) != (lazyMessage != null),
          'Exactly one of message or lazyMessage must be set',
        );

  /// Eager message. Null when [lazyMessage] is set.
  final Object? message;

  /// Lazy message. Evaluated only when the handler actually writes.
  /// Null when [message] is set.
  final EnLoggerLazyMessageProvider? lazyMessage;

  final Severity severity;

  final String? prefix;

  final StackTrace? stackTrace;

  final List<EnLoggerData>? data;

  final EnLoggerLazyDataProvider? dataProvider;
}
