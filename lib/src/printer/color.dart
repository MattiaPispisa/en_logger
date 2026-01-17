/// Color applied on printer messages.
///
/// Defines ANSI color codes for terminal output.
class PrinterColor {
  /// {@template printer_color_custom_constructor}
  /// Creates a [PrinterColor] with a custom ANSI color schema.
  ///
  /// [schema] - The ANSI escape sequence for the color.
  ///
  /// Example schemas:
  /// - red: `\x1B[31m`
  /// - green: `\x1B[32m`
  /// - yellow: `\x1B[33m`
  /// - blue: `\x1B[34m`
  /// - magenta: `\x1B[35m`
  /// - cyan: `\x1B[36m`
  /// {@endtemplate}
  ///
  /// {@macro printer_color_custom_constructor}
  ///
  /// Example:
  /// ```dart
  /// const customColor = PrinterColor.custom(schema: '\x1B[38m');
  /// ```
  const PrinterColor.custom({required this.schema});

  /// Creates a red [PrinterColor].
  ///
  /// Example:
  /// ```dart
  /// const red = PrinterColor.red();
  /// ```
  const PrinterColor.red() : schema = '\x1B[31m';

  /// Creates a green [PrinterColor].
  ///
  /// Example:
  /// ```dart
  /// const green = PrinterColor.green();
  /// ```
  const PrinterColor.green() : schema = '\x1B[32m';

  /// Creates a yellow [PrinterColor].
  ///
  /// Example:
  /// ```dart
  /// const yellow = PrinterColor.yellow();
  /// ```
  const PrinterColor.yellow() : schema = '\x1B[33m';

  /// Creates a blue [PrinterColor].
  ///
  /// Example:
  /// ```dart
  /// const blue = PrinterColor.blue();
  /// ```
  const PrinterColor.blue() : schema = '\x1B[34m';

  /// Creates a magenta [PrinterColor].
  ///
  /// Example:
  /// ```dart
  /// const magenta = PrinterColor.magenta();
  /// ```
  const PrinterColor.magenta() : schema = '\x1B[35m';

  /// Creates a cyan [PrinterColor].
  ///
  /// Example:
  /// ```dart
  /// const cyan = PrinterColor.cyan();
  /// ```
  const PrinterColor.cyan() : schema = '\x1B[36m';

  /// ANSI color schema.
  ///
  /// The escape sequence that defines the color in terminal output.
  final String schema;
}
