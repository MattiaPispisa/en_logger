import 'package:en_logger/en_logger.dart';

/// Color configuration for each [Severity] level.
///
/// Manages the mapping between severity levels and their corresponding
/// dev log colors. Used internally by [DevLogHandler] to colorize
/// log messages based on their severity.
class DevLogColorConfiguration {
  /// Creates a new [DevLogColorConfiguration] with default colors.
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
  DevLogColorConfiguration();

  final Map<Severity, DevLogColor> _configuration = {
    Severity.emergency: const DevLogColor.red(),
    Severity.alert: const DevLogColor.red(),
    Severity.critical: const DevLogColor.red(),
    Severity.error: const DevLogColor.red(),
    Severity.warning: const DevLogColor.yellow(),
    Severity.notice: const DevLogColor.blue(),
    Severity.informational: const DevLogColor.green(),
    Severity.debug: const DevLogColor.cyan(),
  };

  /// Updates the color for a specific [severity] level.
  ///
  /// [severity] - The severity level to update.
  ///
  /// [color] - The color to assign to this severity level.
  ///
  /// Example:
  /// ```dart
  /// final config = DevLogColorConfiguration();
  /// config.setSeverityColor(Severity.error, const DevLogColor.magenta());
  /// ```
  void setSeverityColor(Severity severity, DevLogColor color) {
    _configuration[severity] = color;
  }

  /// Updates the configuration with multiple severity-color mappings.
  ///
  /// [updateConfig] - Map of severity levels to their corresponding colors.
  ///
  /// Example:
  /// ```dart
  /// final config = DevLogColorConfiguration();
  /// config.setSeverityColors({
  ///   Severity.informational: const DevLogColor.magenta(),
  ///   Severity.debug: const DevLogColor.custom(schema: '\x1B[38m'),
  /// });
  /// ```
  void setSeverityColors(Map<Severity, DevLogColor> updateConfig) {
    updateConfig.forEach(setSeverityColor);
  }

  /// Returns the [DevLogColor] for the given [severity] level.
  ///
  /// [severity] - The severity level to get the color for.
  ///
  /// Returns the configured color for [severity], or blue as a fallback
  /// if no color is configured.
  ///
  /// Example:
  /// ```dart
  /// final config = DevLogColorConfiguration();
  /// final color = config.getColor(Severity.error); // red
  /// ```
  DevLogColor getColor(Severity severity) {
    return _configuration[severity] ?? const DevLogColor.blue();
  }
}
