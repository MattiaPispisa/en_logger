import 'package:en_logger/en_logger.dart';

/// Color configuration for each [Severity] level.
///
/// Manages the mapping between severity levels and their corresponding
/// printer colors. Used internally by [PrinterHandler] to colorize
/// log messages based on their severity.
class PrinterColorConfiguration {
  /// Creates a new [PrinterColorConfiguration] with default colors.
  ///
  /// Default color mapping:
  /// - [Severity.emergency] → red
  /// - [Severity.alert] → red
  /// - [Severity.critical] → red
  /// - [Severity.error] → red
  /// - [Severity.warning] → yellow
  /// - [Severity.notice] → blue
  /// - [Severity.informational] → green
  /// - [Severity.debug] → cyan
  PrinterColorConfiguration();

  final Map<Severity, PrinterColor> _configuration = {
    Severity.emergency: const PrinterColor.red(),
    Severity.alert: const PrinterColor.red(),
    Severity.critical: const PrinterColor.red(),
    Severity.error: const PrinterColor.red(),
    Severity.warning: const PrinterColor.yellow(),
    Severity.notice: const PrinterColor.blue(),
    Severity.informational: const PrinterColor.green(),
    Severity.debug: const PrinterColor.cyan(),
  };

  /// Updates the color for a specific [severity] level.
  ///
  /// [severity] - The severity level to update.
  ///
  /// [color] - The color to assign to this severity level.
  ///
  /// Example:
  /// ```dart
  /// final config = PrinterColorConfiguration();
  /// config.setSeverityColor(Severity.error, const PrinterColor.magenta());
  /// ```
  void setSeverityColor(Severity severity, PrinterColor color) {
    _configuration[severity] = color;
  }

  /// Updates the configuration with multiple severity-color mappings.
  ///
  /// [updateConfig] - Map of severity levels to their corresponding colors.
  ///
  /// Example:
  /// ```dart
  /// final config = PrinterColorConfiguration();
  /// config.setSeverityColors({
  ///   Severity.informational: const PrinterColor.magenta(),
  ///   Severity.debug: const PrinterColor.custom(schema: '\x1B[38m'),
  /// });
  /// ```
  void setSeverityColors(Map<Severity, PrinterColor> updateConfig) {
    updateConfig.forEach(setSeverityColor);
  }

  /// Returns the printer color for the given [severity] level.
  ///
  /// [severity] - The severity level to get the color for.
  ///
  /// Returns the configured color for [severity], or blue as a fallback
  /// if no color is configured.
  ///
  /// Example:
  /// ```dart
  /// final config = PrinterColorConfiguration();
  /// final color = config.getColor(Severity.error); // red
  /// ```
  PrinterColor getColor(Severity severity) {
    return _configuration[severity] ?? const PrinterColor.blue();
  }
}
