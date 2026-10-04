/// Formats [message] for console output, applying [colorSchema] and an
/// optional [formattedPrefix] to every line of [message] independently.
///
/// This keeps multi-line messages fully colored regardless of how the sink
/// renders line breaks: some consoles (e.g. a browser's expanded console
/// view) treat each line as a separate event, which resets ANSI state
/// between lines if the color is only applied once at the start of the
/// whole string.
///
/// [formattedPrefix], when not `null`, is prepended (followed by a single
/// space) only to the first line.
///
/// When [useColors] is `false`, no ANSI escape codes are emitted.
String formatConsoleMessage({
  required String message,
  required String colorSchema,
  required bool useColors,
  String? formattedPrefix,
  String resetSchema = '\x1B[0m',
}) {
  final prefixPart = formattedPrefix != null ? '$formattedPrefix ' : '';
  final lines = message.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final linePrefix = i == 0 ? prefixPart : '';
    lines[i] = useColors
        ? '$colorSchema$linePrefix${lines[i]}$resetSchema'
        : '$linePrefix${lines[i]}';
  }

  return lines.join('\n');
}
