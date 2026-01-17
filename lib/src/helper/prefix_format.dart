import 'package:en_logger/en_logger.dart';

/// {@template prefix_format}
/// # PrefixFormat
/// ## Description
/// Prefix formatter for log message prefixes.
///
/// Defines how prefixes are displayed in log messages, including
/// the formatting style and enclosing characters.
///
/// ## Example:
/// ```dart
/// const format = PrefixFormat(
///   startFormat: '[',
///   endFormat: ']',
///   style: PrefixStyle.pascalCase,
/// );
/// final formatted = format.format('API Repository'); // '[ApiRepository]'
/// ```
/// {@endtemplate}
class PrefixFormat {
  /// {@template prefix_format_constructor}
  /// # Constructor
  /// ## Description
  /// Creates a new [PrefixFormat] instance.
  ///
  /// ## Parameters
  /// [startFormat] - Leading string that encloses the prefix (e.g., '[').
  ///
  /// [endFormat] - Trailing string that encloses the prefix (e.g., ']').
  ///
  /// [style] - Style to apply on the prefix text. Defaults to
  ///           [PrefixStyle.uppercaseSnakeCase].
  /// {@endtemplate}
  ///
  /// {@macro prefix_format}
  const PrefixFormat({
    this.startFormat,
    this.endFormat,
    this.style = PrefixStyle.uppercaseSnakeCase,
  });

  /// square bracket format with snake case style.
  /// For example, `[API_REPOSITORY]`.
  const PrefixFormat.snakeSquare()
      : startFormat = '[',
        endFormat = ']',
        style = PrefixStyle.uppercaseSnakeCase;

  /// Leading string that encloses the prefix.
  ///
  /// For example, `[` in `[PREFIX]`.
  final String? startFormat;

  /// Trailing string that encloses the prefix.
  ///
  /// For example, `]` in `[PREFIX]`.
  final String? endFormat;

  /// Style to apply on prefix text.
  ///
  /// See [PrefixStyle] for available styles.
  final PrefixStyle style;

  /// Creates a copy of this [PrefixFormat] with the given fields replaced.
  ///
  /// [startFormat] - New start format. If null, uses the current value.
  ///
  /// [endFormat] - New end format. If null, uses the current value.
  ///
  /// [style] - New style. If null, uses the current value.
  ///
  /// Returns a new [PrefixFormat] instance with the updated values.
  ///
  /// Example:
  /// ```dart
  /// var format = const PrefixFormat(
  ///   startFormat: '[',
  ///   endFormat: ']',
  ///   style: PrefixStyle.pascalCase,
  /// );
  /// format = format.copyWith(startFormat: '{');
  /// // format now has startFormat: '{', endFormat: ']', style: pascalCase
  /// ```
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

  /// Applies the format on [prefix].
  ///
  /// Returns an empty string if [prefix] is null or empty.
  /// Otherwise, applies the [style] to the prefix and encloses it
  /// with [startFormat] and [endFormat].
  ///
  /// [prefix] - The prefix text to format.
  ///
  /// Returns the formatted prefix string.
  ///
  /// Example:
  /// ```dart
  /// const format = PrefixFormat.snakeSquare();
  /// final result = format.format('API Repository'); // '[API_REPOSITORY]'
  /// final empty = format.format(null); // ''
  /// ```
  String format(String? prefix) {
    if (prefix == null || prefix.isEmpty) {
      return '';
    }

    return '$startFormat${style.applyOn(prefix)}$endFormat';
  }
}
