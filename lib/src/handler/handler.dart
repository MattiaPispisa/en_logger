import 'package:en_logger/en_logger.dart';

/// {@template en_logger_handler}
/// # EnLoggerHandler
///
/// ## Description
/// An [EnLoggerHandler] is the one who will actually handle the log message.
/// Implement this abstract class to create custom log handlers.
/// [PrinterHandler] is an example of a [EnLoggerHandler].
/// {@endtemplate}
///
/// {@template en_logger_handler_example}
/// ## Example:
/// ```dart
/// class SentryHandler extends EnLoggerHandler {
///   @override
///   void write(
///     String message, {
///     required Severity severity,
///     String? prefix,
///     StackTrace? stackTrace,
///     List<EnLoggerData>? data,
///   }) {
///     final formattedPrefix = prefixFormat?.format(prefix);
///     final prettyMessage = formattedPrefix != null ?
///       '$formattedPrefix $message' : message;
///     if (severity.atLeastError) {
///       Sentry.captureException(prettyMessage, stackTrace: stackTrace);
///       return;
///     }
///
///     Sentry.captureMessage(prettyMessage);
///     return;
///   }
/// }
/// ```
/// {@endtemplate}
abstract class EnLoggerHandler {
  /// # Constructor
  ///
  /// ## Description
  /// Creates a new [EnLoggerHandler] instance.
  ///
  /// ## Parameters
  /// [prefixFormat] - Optional format for displaying message prefixes.
  /// If not provided, the logger's default prefix format will be used.
  ///
  /// {@macro en_logger_handler}
  /// {@macro en_logger_handler_example}
  EnLoggerHandler({this.prefixFormat});

  /// Prefix format for displaying message prefixes.
  ///
  /// If not set, the logger's default prefix format will be used.
  PrefixFormat? prefixFormat;

  /// Whether this handler should process the log for the given [severity].
  ///
  /// When `false`, [write] is not called and lazy message is not evaluated.
  /// Override to filter by level
  /// (e.g. in production only log error and above).
  ///
  /// Default is `true` (handler always [write]s).
  bool can({required Severity severity, String? prefix}) => true;

  /// Writes a log message.
  ///
  /// This method is called by [EnLogger] only when [can] returns true for
  /// the log severity. Implement this method to define how your handler
  /// processes log messages.
  ///
  /// ## Parameters
  /// [message] - The content to show (already resolved; lazy evaluation
  /// is done at logger level when [can] is true for at least one handler).
  ///
  /// [severity] - The severity level of the log message.
  ///
  /// [prefix] - Optional message prefix.
  /// May be formatted according to [prefixFormat] if set.
  ///
  /// [error] - Optional error object associated with the log message.
  ///
  /// [stackTrace] - Optional stack trace associated with the log message.
  /// Typically provided for error-level messages.
  ///
  /// [data] - Optional list of additional data relating to the message.
  ///
  /// [tags] - Optional map of additional tags to attach to the log message.
  ///
  /// [eventId] - A unique identifier (UUID v4) for this specific log event.
  ///
  /// [timestamp] - The exact [DateTime] when the log event was generated.
  /// Captured immediately upon method call,
  /// **before any async queueing or processing**.
  ///
  /// [sequenceNumber] - A globally incrementing counter starting from 0.
  /// Guarantees the absolute chronological creation order of logs
  /// within the app lifecycle.
  /// {@macro en_logger_handler_example}
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
  });
}
