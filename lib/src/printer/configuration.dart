import 'package:en_logger/en_logger.dart';

/// color configuration for each [Severity]
class PrinterColorConfiguration {
  /// constructor
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

  /// update [severity] with [color]
  void setSeverityColor(Severity severity, PrinterColor color) {
    _configuration[severity] = color;
  }

  /// update configuration with [updateConfig]
  void setSeverityColors(Map<Severity, PrinterColor> updateConfig) {
    updateConfig.forEach(setSeverityColor);
  }

  /// return the [severity] printer color
  PrinterColor getColor(Severity severity) {
    return _configuration[severity] ?? const PrinterColor.blue();
  }
}
