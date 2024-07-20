/// syslog severity levels
enum Severity {
  /// System is unusable
  emergency,

  /// Should be corrected immediately
  alert,

  /// Critical conditions
  critical,

  /// Error conditions
  error,

  /// May indicate that an error will occur if action is not taken
  warning,

  /// Events that are unusual, but not error conditions
  notice,

  /// Normal operational messages that require no action
  informational,

  /// Information useful to developers for debugging the application
  debug;

  /// Severity level.
  /// - Emergency --> 0
  /// - Debug --> 70
  int get level {
    switch (this) {
      case Severity.emergency:
        return 0;
      case Severity.alert:
        return 10;
      case Severity.critical:
        return 20;
      case Severity.error:
        return 30;
      case Severity.warning:
        return 40;
      case Severity.notice:
        return 50;
      case Severity.informational:
        return 60;
      case Severity.debug:
        return 70;
    }
  }

  /// error or more critical
  bool get atLeastError => level <= 30;
}
