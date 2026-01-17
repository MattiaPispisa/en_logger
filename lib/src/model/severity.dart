/// The level of the emergency severity.
const int _emergencyLevel = 0;

/// The level of the alert severity.
const int _alertLevel = 10;

/// The level of the critical severity.
const int _criticalLevel = 20;

/// The level of the error severity.
const int _errorLevel = 30;

/// The level of the warning severity.
const int _warningLevel = 40;

/// The level of the notice severity.
const int _noticeLevel = 50;

/// The level of the informational severity.
const int _informationalLevel = 60;

/// The level of the debug severity.
const int _debugLevel = 70;

/// Syslog severity levels.
///
/// These levels follow the standard syslog severity levels,
/// ordered from most critical to least critical.
enum Severity {
  /// System is unusable.
  ///
  /// Condition: A panic condition.
  ///
  /// Level: `0`
  emergency,

  /// Action must be taken immediately.
  ///
  /// Condition: Should be corrected immediately.
  ///
  /// Level: `10`
  alert,

  /// Critical conditions.
  ///
  /// Condition: Hard device errors.
  ///
  /// Level: `20`
  critical,

  /// Error conditions.
  ///
  /// Level: `30`
  error,

  /// Warning conditions.
  ///
  /// Condition: May indicate that an error will occur if action is not taken.
  ///
  /// Level: `40`
  warning,

  /// Normal but significant conditions.
  ///
  /// Condition: Events that are unusual, but not error conditions.
  ///
  /// Level: `50`
  notice,

  /// Informational messages.
  ///
  /// Condition: Normal operational messages that require no action.
  ///
  /// Level: `60`
  informational,

  /// Debug-level messages.
  ///
  /// Condition: Information useful to developers for debugging the application.
  ///
  /// Level: `70`
  debug;

  /// Severity level as an integer.
  ///
  /// Lower values indicate higher severity.
  /// - [emergency] --> `0`
  /// - [alert] --> `10`
  /// - [critical] --> `20`
  /// - [error] --> `30`
  /// - [warning] --> `40`
  /// - [notice] --> `50`
  /// - [informational] --> `60`
  /// - [debug] --> `70`
  ///
  /// ##Example:
  /// ```dart
  /// Severity.error.level; // 30
  /// Severity.debug.level; // 70
  /// ```
  int get level {
    switch (this) {
      case Severity.emergency:
        return _emergencyLevel;
      case Severity.alert:
        return _alertLevel;
      case Severity.critical:
        return _criticalLevel;
      case Severity.error:
        return _errorLevel;
      case Severity.warning:
        return _warningLevel;
      case Severity.notice:
        return _noticeLevel;
      case Severity.informational:
        return _informationalLevel;
      case Severity.debug:
        return _debugLevel;
    }
  }

  /// Returns `true` if this severity is error or more critical.
  ///
  /// This includes [emergency], [alert], [critical], and [error].
  ///
  /// Example:
  /// ```dart
  /// Severity.error.atLeastError; // true
  /// Severity.warning.atLeastError; // false
  /// ```
  bool get atLeastError => level <= _errorLevel;
}
