import 'dart:async';

import 'package:en_logger/en_logger.dart';

/// Entity that manages logs.
/// It contains handlers.
///
/// Each time a new log is created, the handlers are invoked to write
/// the message according to their implementation.
///
/// [PrinterHandler] is an example of a [EnLoggerHandler].
class EnLogger {
  /// constructor
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

  /// add a new [handler]
  void addHandler(EnLoggerHandler handler) => _handlers.add(
        handler..prefixFormat = handler.prefixFormat ?? _defaultPrefixFormat,
      );

  /// add a list of [handlers]
  void addHandlers(List<EnLoggerHandler> handlers) {
    handlers.forEach(addHandler);
  }

  /// remove [handler]
  void removeHandler(EnLoggerHandler handler) {
    _handlers.remove(handler);
  }

  /// remove [handlers]
  void removeHandlers(List<EnLoggerHandler> handlers) {
    handlers.forEach(removeHandler);
  }

  /// remove every handler
  void removeAllHandlers() {
    _handlers.clear();
  }

  /// create from `this` a new instance with:
  ///
  /// - a pre-configured [prefix]
  /// - current [EnLoggerHandler] configured
  EnLogger getConfiguredInstance({String? prefix}) {
    return _EnLoggerInstance(
      prefix: prefix,
      defaultPrefixFormat: _defaultPrefixFormat?.copyWith(),
      handlers: List.of(_handlers),
    );
  }

  /// System is unusable
  ///
  /// Condition: A panic condition
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

  /// Action must be taken immediately
  ///
  /// Condition: A condition that should be corrected immediately,
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

  /// Critical conditions
  ///
  /// Condition: Hard device errors.
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

  /// Error conditions
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

  /// Warning conditions
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

  /// Normal but significant conditions
  ///
  /// Condition: Conditions that are not error conditions,
  /// but that may require special handling
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

  /// Informational messages
  ///
  /// Condition: Confirmation that the program is working as expected
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

  /// Debug-level messages
  ///
  /// Condition: Messages that contain information
  /// normally of use only when debugging a program
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
