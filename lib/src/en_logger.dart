import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:en_logger/en_logger.dart';

part '_helper.dart';

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
/// [DevLogHandler] is an example of a [EnLoggerHandler].
///
/// ## Lazy evaluation
/// The "lazy" variants of the log methods (e.g. [lazyDebug]) accept
/// closures that are evaluated only when at least one handler
/// will write the log. This allows to skip expensive computations
/// when the log level is disabled.
///
/// ## Tags & Zones
/// [EnLogger] can automatically extract contextual data (tags)
/// from Dart's [Zone.current] and attach them to every log event.
///
/// By providing `zoneContextKeys` to the constructor, the logger will capture
/// only the specified keys from the current execution zone.
///
/// Additionally, every logging method accepts its own `tags` parameter.
/// The handlers will receive a single, merged, and sanitized map
/// containing both the requested zone tags and the method-specific tags.
///
/// ## Example:
///
/// ```dart
/// final logger = EnLogger(
///   zoneContextKeys: {#userId, #tenantId},
///   defaultPrefixFormat: const PrefixFormat(
///     startFormat: '[',
///     endFormat: ']',
///   ),
/// )
///   ..addHandlers([
///     DevLogHandler(),
///   ]);
///
/// runZoned(
///   () {
///     logger
///       ..debug('a debug message',prefix: 'API Repository')
///       // [API_REPOSITORY] a debug message
///       ..lazyDebug(() => 'a lazy debug message', prefix: 'API Repository');
///       // [API_REPOSITORY] a lazy debug message
///       // evaluated only when at least one handler will write (can returns true)
///   },
///  zoneValues: {
///    #userId: 123,
///    #tenantId: 'tenant-xyz',
///  },
/// );
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
  /// [zoneContextKeys] - Optional set of keys to extract
  /// from the current execution zone and attach as tags to every log event.
  ///
  /// {@macro en_logger}
  factory EnLogger({
    List<EnLoggerHandler>? handlers,
    PrefixFormat? defaultPrefixFormat,
    Set<Object>? zoneContextKeys,
    bool? includeCallerInfo,
  }) {
    return EnLogger._(
      handlers: handlers
              ?.map(
                (h) => h..prefixFormat ??= defaultPrefixFormat,
              )
              .toList() ??
          <EnLoggerHandler>[],
      defaultPrefixFormat: defaultPrefixFormat,
      prefix: null,
      zoneContextKeys: zoneContextKeys,
      sharedState: _EnLoggerSharedState(),
      includeCallerInfo: includeCallerInfo,
    );
  }

  EnLogger._({
    required List<EnLoggerHandler> handlers,
    required PrefixFormat? defaultPrefixFormat,
    required String? prefix,
    required Set<Object>? zoneContextKeys,
    required _EnLoggerSharedState sharedState,
    required bool? includeCallerInfo,
  })  : _handlers = handlers,
        _defaultPrefixFormat = defaultPrefixFormat,
        _prefix = prefix,
        _closed = false,
        _instances = {},
        _pendingTasks = {},
        _sharedState = sharedState,
        _zoneContextKeys = zoneContextKeys ?? {},
        _includeCallerInfo = includeCallerInfo ?? false;

  static int _sequenceNumber = 0;

  final _EnLoggerSharedState _sharedState;
  final List<EnLoggerHandler> _handlers;
  final PrefixFormat? _defaultPrefixFormat;
  final String? _prefix;
  final bool _includeCallerInfo;

  final Set<Object> _zoneContextKeys;

  bool _closed;

  /// Whether the logger is closed ([close] has been **called**).
  bool get closed => _closed;

  /// Set of instances created ([getConfiguredInstance]) from this logger.
  final Set<EnLogger> _instances;

  /// Set of pending tasks to write logs.
  final Set<Future<void>> _pendingTasks;

  /// Adds a new [handler] to process log messages.
  ///
  /// The handler's prefixFormat will be set to the logger's
  /// default prefixFormat if the handler doesn't have one configured.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger();
  /// logger.addHandler(DevLogHandler());
  /// logger.debug('message'); // DevLogHandler will write the message
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
  ///   DevLogHandler(),
  ///   SentryHandler(),
  /// ]);
  /// logger.debug('message'); // DevLogHandler and SentryHandler will write the message
  /// ```
  void addHandlers(List<EnLoggerHandler> handlers) {
    handlers.forEach(addHandler);
  }

  /// Removes a [handler] from the logger.
  ///
  /// ## Example:
  /// ```dart
  /// final handler = DevLogHandler();
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
  /// final handler1 = DevLogHandler();
  /// final handler2 = DevLogHandler();
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
  ///   ..addHandler(DevLogHandler())
  ///   ..addHandler(DevLogHandler());
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
  /// [zoneContextKeys] - Optional set of keys to extract
  /// from the current execution zone and attach as tags to every log event.
  /// [zoneContextKeys] provided here will be merged with parent logger's keys.
  ///
  /// [includeCallerInfo] - If `true` `callerInfo` will be calculated
  /// and provided to handlers
  ///
  /// ## Returns
  /// Returns a new [EnLogger] instance with the configured prefix and handlers.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  ///
  /// // Create a configured instance with a default prefix
  /// final apiLogger = logger.getConfiguredInstance(prefix: 'API Repository');
  /// apiLogger.debug('a debug message'); // [API_REPOSITORY] a debug message
  ///
  /// // Original logger still works without prefix
  /// logger.debug('a debug message'); // a debug message
  /// ```
  EnLogger getConfiguredInstance({
    String? prefix,
    Set<Object>? zoneContextKeys,
    bool? includeCallerInfo,
  }) {
    final mergedZoneKeys = <Object>{
      ..._zoneContextKeys,
      if (zoneContextKeys != null) ...zoneContextKeys,
    };

    final instance = EnLogger._(
      prefix: prefix ?? _prefix,
      defaultPrefixFormat: _defaultPrefixFormat?.copyWith(),
      handlers: List.of(_handlers),
      zoneContextKeys: mergedZoneKeys,
      sharedState: _sharedState,
      includeCallerInfo: includeCallerInfo ?? _includeCallerInfo,
    );
    _instances.add(instance);
    return instance;
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
  /// [message] - The error message or object to log.
  ///
  /// [prefix] - Optional prefix for this log message. Overrides the default
  ///            prefix if this logger was created with [getConfiguredInstance].
  ///
  /// [error] - Optional error object associated with the log message.
  ///
  /// [stackTrace] - Optional stack trace associated with the error.
  ///
  /// [data] - Optional list of additional data to attach to the log message.
  /// {@endtemplate}
  ///
  /// [tags] - Optional map of additional tags to attach to the log message.
  ///
  /// ## Example
  /// ```dart
  /// final logger = EnLogger()..addHandler(DevLogHandler());
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
    Object message, {
    String? prefix,
    Object? error,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.emergency,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        data: data,
        tags: tags,
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
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  /// logger.alert(
  ///   'Database connection lost',
  ///   stackTrace: StackTrace.current,
  /// );
  /// ```
  void alert(
    Object message, {
    String? prefix,
    Object? error,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.alert,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        data: data,
        tags: tags,
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
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  /// logger.critical(
  ///   'Disk full',
  ///   stackTrace: StackTrace.current,
  /// );
  /// ```
  void critical(
    Object message, {
    String? prefix,
    Object? error,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.critical,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        data: data,
        tags: tags,
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
  /// final logger = EnLogger()..addHandler(DevLogHandler());
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
    Object message, {
    String? prefix,
    Object? error,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.error,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        data: data,
        tags: tags,
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
  ///
  /// [tags] - Optional map of additional tags to attach to the log message.
  /// {@endtemplate}
  ///
  /// ## Example
  /// ```dart
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  /// logger.warning('Low disk space');
  /// ```
  void warning(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.warning,
        prefix: prefix,
        data: data,
        tags: tags,
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
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  /// logger.normal('User logged in');
  /// ```
  void normal(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.notice,
        prefix: prefix,
        data: data,
        tags: tags,
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
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  /// logger.info('Application started');
  /// ```
  void info(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.informational,
        prefix: prefix,
        data: data,
        tags: tags,
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
  /// final logger = EnLogger()..addHandler(DevLogHandler());
  /// logger.debug('a debug message');
  ///
  /// // With prefix
  /// logger.debug('a debug message', prefix: 'Custom prefix');
  /// ```
  void debug(
    Object message, {
    String? prefix,
    List<EnLoggerData>? data,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        message: message,
        severity: Severity.debug,
        prefix: prefix,
        data: data,
        tags: tags,
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
  /// [error] - Optional error object associated with the log message.
  ///
  /// [stackTrace] - Optional stack trace associated with the log message.
  ///
  /// [dataProvider] - Optional closure that returns the list of additional
  /// data to attach to the log message. Called only when at least one handler
  /// will write.
  ///
  /// [tags] - Optional map of additional tags to attach to the log message.
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
    Object? error,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.emergency,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
        tags: tags,
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
    Object? error,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.alert,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
        tags: tags,
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
    Object? error,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.critical,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
        tags: tags,
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
    Object? error,
    StackTrace? stackTrace,
    EnLoggerLazyDataProvider? dataProvider,
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.error,
        prefix: prefix,
        error: error,
        stackTrace: stackTrace,
        dataProvider: dataProvider,
        tags: tags,
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
  ///
  /// [tags] - Optional map of additional tags to attach to the log message.
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
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.warning,
        prefix: prefix,
        dataProvider: dataProvider,
        tags: tags,
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
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.notice,
        prefix: prefix,
        dataProvider: dataProvider,
        tags: tags,
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
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.informational,
        prefix: prefix,
        dataProvider: dataProvider,
        tags: tags,
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
    Map<String, dynamic>? tags,
  }) {
    _log(
      _BaseEnLogDataDto(
        lazyMessage: messageProvider,
        severity: Severity.debug,
        prefix: prefix,
        dataProvider: dataProvider,
        tags: tags,
      ),
    );
  }

  /// Closes the logger.
  ///
  /// Waits for all pending "write" operations
  /// before closing the logger.
  ///
  /// Clear every handler and created instances.
  ///
  /// Use [closed] to check if the logger has been requested to close.
  ///
  /// ## Example:
  /// ```dart
  /// final logger = EnLogger()..addHandler(DevLogHandler())..lazyDebug(() {
  ///   final heavyLog = await compute();
  ///   return heavyLog.toString();
  /// });
  /// await logger.close(); // waits for the heavy log to be written then close the logger
  /// logger.debug('message'); // logger is closed, so this message won't be written
  /// ```
  Future<void> close() async {
    if (_closed) {
      return;
    }

    _closed = true;

    if (_pendingTasks.isNotEmpty) {
      await Future.wait(_pendingTasks.map((t) => t.catchError((_) {})));
    }

    _handlers.clear();
    await Future.wait(_instances.map((i) => i.close()));
    _instances.clear();
  }

  /// Disposes the logger.
  ///
  /// Synchronous version of [close] that:
  /// - **doesn't wait** for the completion of the pending tasks;
  /// - **ignores** the result of the [close].
  void dispose() {
    close().ignore();
  }

  void _log(_BaseEnLogDataDto data) {
    if (_closed) {
      return;
    }

    if (_handlers.isEmpty) {
      return;
    }

    final handlersToWrite = _handlers.where(
      (h) => h.can(
        severity: data.severity,
        prefix: data.prefix ?? _prefix,
      ),
    );

    if (handlersToWrite.isEmpty) {
      return;
    }

    final tags = <String, dynamic>{};
    for (final key in _zoneContextKeys) {
      final value = Zone.current[key];
      if (value != null) {
        tags[key is Symbol ? key.name : key.toString()] = value;
      }
    }
    tags.addAll(data.tags ?? {});

    final richData = data.toData(
      timestamp: DateTime.now(),
      tags: _sanitizeTags(tags),
      eventId: _generateUuidV4(),
      sequenceNumber: _sequenceNumber++,
      isolateName: Isolate.current.debugName,
      callerInfo: _includeCallerInfo ? _callerInfo() : null,
    );

    /// wait for the completion of the previous log task
    /// to maintain the order of logs
    final currentTask = _sharedState.lastLogTask.then<FutureOr<void>>((_) {
      return _asyncWrite(richData, handlersToWrite: handlersToWrite);
    })
      ..ignore();

    _sharedState.lastLogTask = currentTask;

    _pendingTasks.add(currentTask);

    currentTask.whenComplete(() {
      _pendingTasks.remove(currentTask);
    }).ignore();
    return;
  }

  // The write operations of the handlers are managed in a
  // separate task since attachments with unknown sizes might be present.
  Future<void> _asyncWrite(
    _EnLogDataDto richData, {
    required Iterable<EnLoggerHandler> handlersToWrite,
  }) async {
    final resolvedMessage = richData.lazyMessage != null
        ? (await richData.lazyMessage!())
        : richData.message;

    final resolvedData = richData.dataProvider != null
        ? await richData.dataProvider!()
        : richData.data;

    final tasks = <Future<void>>[];

    final message = resolvedMessage.toString();
    for (final handler in handlersToWrite) {
      FutureOr<void> futureOrWrite() async => handler.write(
            message,
            error: richData.error,
            severity: richData.severity,
            prefix: richData.prefix ?? _prefix,
            data: resolvedData,
            stackTrace: richData.stackTrace,
            eventId: richData.eventId,
            timestamp: richData.timestamp,
            tags: richData.tags ?? {},
            sequenceNumber: richData.sequenceNumber,
            callerInfo: richData.callerInfo,
            isolateName: richData.isolateName,
          );
      tasks.add(Future.sync(futureOrWrite));
    }

    await Future.wait(tasks);
    return;
  }
}

class _EnLoggerSharedState {
  Future<void> lastLogTask = Future.value();
}

class _BaseEnLogDataDto {
  const _BaseEnLogDataDto({
    required this.severity,
    this.prefix,
    this.stackTrace,
    this.error,
    this.data,
    this.dataProvider,
    this.message,
    this.lazyMessage,
    this.tags,
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

  final Object? error;

  final StackTrace? stackTrace;

  final List<EnLoggerData>? data;

  final EnLoggerLazyDataProvider? dataProvider;

  final Map<String, dynamic>? tags;

  _EnLogDataDto toData({
    required Map<String, dynamic> tags,
    required DateTime timestamp,
    required String eventId,
    required int sequenceNumber,
    required String? isolateName,
    required String? callerInfo,
  }) {
    return _EnLogDataDto(
      tags: tags,
      timestamp: timestamp,
      eventId: eventId,
      sequenceNumber: sequenceNumber,
      isolateName: isolateName,
      callerInfo: callerInfo,
      message: message,
      lazyMessage: lazyMessage,
      severity: severity,
      prefix: prefix,
      error: error,
      stackTrace: stackTrace,
      data: data,
      dataProvider: dataProvider,
    );
  }
}

class _EnLogDataDto extends _BaseEnLogDataDto {
  const _EnLogDataDto({
    required this.timestamp,
    required this.eventId,
    required this.sequenceNumber,
    required super.severity,
    this.isolateName,
    this.callerInfo,
    super.tags,
    super.message,
    super.lazyMessage,
    super.prefix,
    super.error,
    super.stackTrace,
    super.data,
    super.dataProvider,
  });

  final DateTime timestamp;

  final String eventId;

  final int sequenceNumber;

  final String? isolateName;

  final String? callerInfo;
}
