import 'dart:async';
import 'dart:developer' as developer;

import 'package:en_logger/en_logger.dart';

export './color.dart';
export './configuration.dart';

/// PrinterHandler log callback
typedef DeveloperLogCallback = void Function(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level,
  String name,
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
});

/// {@template printer_handler}
/// # PrinterHandler
/// ## Description
/// Concrete implementation of [EnLoggerHandler].
///
/// Writes messages to the developer console using [developer.log].
///
/// Supports color configuration per severity level and message filtering.
///
/// ## Example:
/// ```dart
/// final printer = PrinterHandler()
///   ..configure({
///     Severity.notice: const PrinterColor.green(),
///   });
///
/// final logger = EnLogger()..addHandler(printer);
/// logger.debug('a debug message');
/// ```
/// {@endtemplate}
class PrinterHandler extends EnLoggerHandler {
  /// {@template printer_handler_constructor}
  /// # Constructor
  /// ## Description
  /// Creates a new [PrinterHandler] instance.
  ///
  /// ## Parameters
  /// [prefixFormat] - Format for displaying message prefixes.
  /// Defaults to [PrefixFormat.snakeSquare].
  ///
  /// [writeIfContains] - Optional list of strings. Messages will only be
  /// written if they contain at least one of these strings (OR logic).
  ///
  /// [writeIfNotContains] - Optional list of strings. Messages will only be
  /// written if they don't contain any of these strings
  /// (AND logic with [writeIfContains]).
  /// {@endtemplate}
  ///
  /// {@macro printer_handler}
  factory PrinterHandler({
    PrefixFormat? prefixFormat,
    List<String>? writeIfContains,
    List<String>? writeIfNotContains,
  }) {
    return PrinterHandler._(
      prefixFormat: prefixFormat,
      writeIfContains: writeIfContains,
      writeIfNotContains: writeIfNotContains,
      logCallback: developer.log,
    );
  }

  /// Creates a [PrinterHandler] with a custom [logCallback].
  ///
  /// Use this factory when you need to customize how log messages are written,
  /// for example, to capture logs for testing or redirect them to a different
  /// output.
  factory PrinterHandler.custom({
    required DeveloperLogCallback logCallback,
    PrefixFormat? prefixFormat,
    List<String>? writeIfContains,
    List<String>? writeIfNotContains,
  }) {
    return PrinterHandler._(
      prefixFormat: prefixFormat,
      writeIfContains: writeIfContains,
      writeIfNotContains: writeIfNotContains,
      logCallback: logCallback,
    );
  }

  PrinterHandler._({
    required DeveloperLogCallback logCallback,
    this.writeIfContains,
    this.writeIfNotContains,
    PrefixFormat? prefixFormat,
  })  : _logCallback = logCallback,
        super(
          prefixFormat: prefixFormat ?? const PrefixFormat.snakeSquare(),
        );

  final PrinterColorConfiguration _configuration = PrinterColorConfiguration();

  final DeveloperLogCallback _logCallback;

  /// Write text only if it contains one of the strings in this list (OR logic).
  ///
  /// If set, messages will only be written if they contain at least one
  /// of the strings in this list.
  final List<String>? writeIfContains;

  /// Write text only if it doesn't contain any of the strings in this list.
  ///
  /// If set, messages will only be written if they don't contain any
  /// of the strings in this list. This works in conjunction with
  /// [writeIfContains] (AND logic).
  final List<String>? writeIfNotContains;

  /// Configures printer colors for severity levels.
  ///
  /// Updates the color configuration for the specified severity levels.
  /// Severity levels not in [configuration] will keep their default colors.
  ///
  /// [configuration] - Map of severity levels to their corresponding colors.
  ///
  /// Example:
  /// ```dart
  /// final printer = PrinterHandler();
  /// printer.configure({
  ///   Severity.informational: const PrinterColor.magenta(),
  ///   Severity.debug: const PrinterColor.custom(schema: '\x1B[38m'),
  /// });
  /// ```
  void configure(Map<Severity, PrinterColor> configuration) {
    _configuration.setSeverityColors(configuration);
  }

  void _prettyPrint(
    String message,
    String? prefix,
    Severity severity,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  ) {
    var prettyMessage = '$message\x1B[0m';
    if (prefixFormat != null && prefix != null) {
      prettyMessage = '${prefixFormat!.format(prefix)} $prettyMessage';
    }
    prettyMessage = '${_configuration.getColor(severity).schema}$prettyMessage';

    if (writeIfContains != null &&
        !writeIfContains!.any((element) => prettyMessage.contains(element))) {
      return;
    }

    if (writeIfNotContains != null &&
        writeIfNotContains!.any((element) => prettyMessage.contains(element))) {
      return;
    }

    _logCallback(
      prettyMessage,
      time: DateTime.now().toUtc(),
      level: severity.level,
      stackTrace: stackTrace,
    );
  }

  @override
  void write(
    String message, {
    required Severity severity,
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  }) {
    return _prettyPrint(
      message,
      prefix,
      severity,
      stackTrace,
      data,
    );
  }
}
