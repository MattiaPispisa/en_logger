/// Color applied on dev log messages.
///
/// Defines ANSI color codes for terminal output.
class DevLogColor {
  /// {@template dev_log_color_custom_constructor}
  /// Creates a [DevLogColor] with a custom ANSI color schema.
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
  /// Example:
  /// ```dart
  /// const customColor = DevLogColor.custom(schema: '\x1B[38m');
  /// ```
  const DevLogColor.custom({required this.schema});

  /// Creates a red [DevLogColor].
  ///
  /// Example:
  /// ```dart
  /// const red = DevLogColor.red();
  /// ```
  const DevLogColor.red() : schema = '\x1B[31m';

  /// Creates a green [DevLogColor].
  ///
  /// Example:
  /// ```dart
  /// const green = DevLogColor.green();
  /// ```
  const DevLogColor.green() : schema = '\x1B[32m';

  /// Creates a yellow [DevLogColor].
  ///
  /// Example:
  /// ```dart
  /// const yellow = DevLogColor.yellow();
  /// ```
  const DevLogColor.yellow() : schema = '\x1B[33m';

  /// Creates a blue [DevLogColor].
  ///
  /// Example:
  /// ```dart
  /// const blue = DevLogColor.blue();
  /// ```
  const DevLogColor.blue() : schema = '\x1B[34m';

  /// Creates a magenta [DevLogColor].
  ///
  /// Example:
  /// ```dart
  /// const magenta = DevLogColor.magenta();
  /// ```
  const DevLogColor.magenta() : schema = '\x1B[35m';

  /// Creates a cyan [DevLogColor].
  ///
  /// Example:
  /// ```dart
  /// const cyan = DevLogColor.cyan();
  /// ```
  const DevLogColor.cyan() : schema = '\x1B[36m';

  /// ANSI color schema.
  ///
  /// The escape sequence that defines the color in terminal output.
  final String schema;
}
