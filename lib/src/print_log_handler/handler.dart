import 'package:en_logger/en_logger.dart';
import 'package:en_logger/src/ansi/ansi_support.dart';
import 'package:en_logger/src/ansi/message_formatter.dart';

/// PrintLogHandler print callback signature.
typedef PrintLogCallback = void Function(Object? object);

/// {@template print_log_handler}
/// # PrintLogHandler
/// ## Description
/// Concrete implementation of [EnLoggerHandler].
///
/// Writes messages to the console using [print].
///
/// Useful in contexts where `dart:developer`'s `log` is not ideal, such as
/// CLI tools, scripts, and tests.
///
/// Supports color configuration per severity level and message filtering,
/// same as [DevLogHandler].
///
/// ## Example:
/// ```dart
/// final printLog = PrintLogHandler()
///   ..configure({
///     Severity.notice: const DevLogColor.green(),
///   });
///
/// final logger = EnLogger()..addHandler(printLog);
/// logger.debug('a debug message');
/// ```
/// {@endtemplate}
class PrintLogHandler extends EnLoggerHandler {
  /// {@template print_log_handler_constructor}
  /// # Constructor
  /// ## Description
  /// Creates a new [PrintLogHandler] instance.
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
  ///
  /// [useColors] - Whether to emit ANSI color codes. Defaults to `null`,
  /// which auto-detects support for the current environment.
  /// {@endtemplate}
  ///
  /// {@macro print_log_handler}
  factory PrintLogHandler({
    PrefixFormat? prefixFormat,
    List<String>? writeIfContains,
    List<String>? writeIfNotContains,
    bool? useColors,
  }) {
    return PrintLogHandler._(
      prefixFormat: prefixFormat,
      writeIfContains: writeIfContains,
      writeIfNotContains: writeIfNotContains,
      useColors: useColors,
      // ignore: avoid_print
      printCallback: print,
    );
  }

  /// Creates a [PrintLogHandler] with a custom [printCallback].
  ///
  /// Use this factory when you need to customize how log messages are
  /// written, for example, to capture logs for testing or redirect them
  /// to a different output.
  factory PrintLogHandler.custom({
    required PrintLogCallback printCallback,
    PrefixFormat? prefixFormat,
    List<String>? writeIfContains,
    List<String>? writeIfNotContains,
    bool? useColors,
  }) {
    return PrintLogHandler._(
      prefixFormat: prefixFormat,
      writeIfContains: writeIfContains,
      writeIfNotContains: writeIfNotContains,
      useColors: useColors,
      printCallback: printCallback,
    );
  }

  PrintLogHandler._({
    required PrintLogCallback printCallback,
    this.writeIfContains,
    this.writeIfNotContains,
    PrefixFormat? prefixFormat,
    bool? useColors,
  })  : _printCallback = printCallback,
        _useColors = useColors ?? supportsAnsiColors,
        super(
          prefixFormat: prefixFormat ?? const PrefixFormat.snakeSquare(),
        );

  final DevLogColorConfiguration _configuration = DevLogColorConfiguration();

  final PrintLogCallback _printCallback;

  /// Whether ANSI color codes are emitted.
  final bool _useColors;

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

  /// Configures print log colors for severity levels.
  ///
  /// Updates the color configuration for the specified severity levels.
  /// Severity levels not in [configuration] will keep their default colors.
  ///
  /// [configuration] - Map of severity levels to their corresponding colors.
  ///
  /// Example:
  /// ```dart
  /// final printLog = PrintLogHandler();
  /// printLog.configure({
  ///   Severity.informational: const DevLogColor.magenta(),
  ///   Severity.debug: const DevLogColor.custom(schema: '\x1B[38m'),
  /// });
  /// ```
  void configure(Map<Severity, DevLogColor> configuration) {
    _configuration.setSeverityColors(configuration);
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
    var content = message;
    if (error != null) {
      content = '$content\nError: $error';
    }
    if (stackTrace != null) {
      content = '$content\n$stackTrace';
    }

    final formattedPrefix = (prefixFormat != null && prefix != null)
        ? prefixFormat!.format(prefix)
        : null;

    final prettyMessage = formatConsoleMessage(
      message: content,
      colorSchema: _configuration.getColor(severity).schema,
      useColors: _useColors,
      formattedPrefix: formattedPrefix,
    );

    if (writeIfContains != null &&
        !writeIfContains!.any(prettyMessage.contains)) {
      return;
    }

    if (writeIfNotContains != null &&
        writeIfNotContains!.any(prettyMessage.contains)) {
      return;
    }

    _printCallback(prettyMessage);
  }
}
