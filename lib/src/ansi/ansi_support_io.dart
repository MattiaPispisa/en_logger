import 'dart:io' as io;

/// Whether the current environment supports ANSI escape codes.
///
/// Delegates to `dart:io`'s `stdout.supportsAnsiEscapes`.
bool get supportsAnsiColors => io.stdout.supportsAnsiEscapes;
