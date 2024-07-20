/// color applied on printer message
class PrinterColor {
  /// printer color constructor for custom color
  ///
  /// example of schema:
  /// - red `\x1B[31m`
  /// - green `\x1B[32m`
  const PrinterColor.custom({required this.schema});

  /// red
  const PrinterColor.red() : schema = '\x1B[31m';

  /// green
  const PrinterColor.green() : schema = '\x1B[32m';

  /// yellow
  const PrinterColor.yellow() : schema = '\x1B[33m';

  /// blue
  const PrinterColor.blue() : schema = '\x1B[34m';

  /// magenta
  const PrinterColor.magenta() : schema = '\x1B[35m';

  /// cyan
  const PrinterColor.cyan() : schema = '\x1B[36m';

  /// schema color
  final String schema;
}
