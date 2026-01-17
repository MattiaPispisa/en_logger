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

  /// Writes a log message.
  ///
  /// This method is called by [EnLogger] whenever a log message
  /// needs to be processed.
  /// Implement this method to define how your handler processes log messages.
  ///
  /// ## Parameters
  /// [message] - The content to show.
  ///
  /// [severity] - The severity level of the log message.
  ///
  /// [prefix] - Optional message prefix.
  /// May be formatted according to [prefixFormat] if set.
  ///
  /// [stackTrace] - Optional stack trace associated with the log message.
  /// Typically provided for error-level messages.
  ///
  /// [data] - Optional list of additional data relating to the message.
  ///
  /// {@macro en_logger_handler_example}
  void write(
    String message, {
    required Severity severity,
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  });
}
