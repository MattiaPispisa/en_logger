import 'package:en_logger/en_logger.dart';

/// An EnLoggerHandler is the one who will actually handle the log message.
///
/// [PrinterHandler] is an example of a [EnLoggerHandler]
abstract class EnLoggerHandler {
  /// constructor
  EnLoggerHandler({this.prefixFormat});

  /// prefix format
  PrefixFormat? prefixFormat;

  /// [message] the content to show
  /// [prefix] message prefix
  /// [severity]
  /// [stackTrace] optional stackTrace
  /// [data] list of data relating to the message
  void write(
    String message, {
    required Severity severity,
    String? prefix,
    StackTrace? stackTrace,
    List<EnLoggerData>? data,
  });
}
