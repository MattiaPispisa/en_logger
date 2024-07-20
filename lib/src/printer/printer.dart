import 'dart:developer' as developer;

import 'package:en_logger/en_logger.dart';

export './color.dart';
export './configuration.dart';

/// concrete implementation of [EnLoggerHandler]
///
/// write message on developer console
class PrinterHandler extends EnLoggerHandler {
  /// [writeIfContains] in OR
  /// [writeIfNotContains] in AND
  PrinterHandler({
    super.prefixFormat,
    this.writeIfContains,
    this.writeIfNotContains,
  });

  final PrinterColorConfiguration _configuration = PrinterColorConfiguration();

  /// write text only if contains one of the [writeIfContains]
  final List<String>? writeIfContains;

  /// write text only if not contains any of the [writeIfNotContains]
  final List<String>? writeIfNotContains;

  /// configure printer colors
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

    developer.log(
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
