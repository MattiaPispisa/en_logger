import 'package:en_logger/src/ansi/ansi_support_stub.dart'
    if (dart.library.io) 'package:en_logger/src/ansi/ansi_support_io.dart'
    as platform;

/// Whether the current environment is believed to support ANSI escape
/// codes for colored terminal output.
///
/// Uses `dart:io`'s `stdout.supportsAnsiEscapes` when available, and
/// falls back to `false` on platforms where `dart:io` is not available
/// (e.g. Web), where colored output can't be reliably detected or would
/// otherwise leak raw escape codes into the console.
bool get supportsAnsiColors => platform.supportsAnsiColors;
