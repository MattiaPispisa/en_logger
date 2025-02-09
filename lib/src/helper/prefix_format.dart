import 'package:en_logger/en_logger.dart';

/// prefix formatter
class PrefixFormat {
  /// constructor
  const PrefixFormat({
    this.startFormat,
    this.endFormat,
    this.style = PrefixStyle.uppercaseSnakeCase,
  });

  /// constructor with snake case and square bracket format
  const PrefixFormat.snakeSquare()
      : startFormat = '[',
        endFormat = ']',
        style = PrefixStyle.uppercaseSnakeCase;

  /// leading string that enclose the prefix
  final String? startFormat;

  /// trailing string that enclose the prefix
  final String? endFormat;

  /// style to apply on prefix
  final PrefixStyle style;

  /// standard copy with method
  PrefixFormat copyWith({
    String? startFormat,
    String? endFormat,
    PrefixStyle? style,
  }) {
    return PrefixFormat(
      endFormat: endFormat ?? this.endFormat,
      startFormat: startFormat ?? this.startFormat,
      style: style ?? this.style,
    );
  }

  /// apply format on [prefix]
  String format(String? prefix) {
    if (prefix == null || prefix.isEmpty) {
      return '';
    }

    return '$startFormat${style.applyOn(prefix)}$endFormat';
  }
}
