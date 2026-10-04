import 'package:en_logger/src/ansi/ansi_support.dart';
import 'package:en_logger/src/ansi/message_formatter.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('supportsAnsiColors', () {
    test('returns a bool without throwing', () {
      expect(() => supportsAnsiColors, returnsNormally);
      expect(supportsAnsiColors, isA<bool>());
    });
  });

  group('formatConsoleMessage', () {
    test('colors a single-line message', () {
      final result = formatConsoleMessage(
        message: 'hello',
        colorSchema: '\x1B[31m',
        useColors: true,
      );

      expect(result, '\x1B[31mhello\x1B[0m');
    });

    test('colors every line of a multi-line message', () {
      final result = formatConsoleMessage(
        message: 'line1\nline2\nline3',
        colorSchema: '\x1B[31m',
        useColors: true,
      );

      expect(
        result,
        '\x1B[31mline1\x1B[0m\n\x1B[31mline2\x1B[0m\n\x1B[31mline3\x1B[0m',
      );
    });

    test('adds the prefix only on the first line', () {
      final result = formatConsoleMessage(
        message: 'line1\nline2',
        colorSchema: '\x1B[31m',
        useColors: true,
        formattedPrefix: '[PREFIX]',
      );

      expect(
        result,
        '\x1B[31m[PREFIX] line1\x1B[0m\n\x1B[31mline2\x1B[0m',
      );
    });

    test('emits no ANSI codes when useColors is false', () {
      final result = formatConsoleMessage(
        message: 'line1\nline2',
        colorSchema: '\x1B[31m',
        useColors: false,
        formattedPrefix: '[PREFIX]',
      );

      expect(result, '[PREFIX] line1\nline2');
    });

    test('handles an empty message', () {
      final result = formatConsoleMessage(
        message: '',
        colorSchema: '\x1B[31m',
        useColors: true,
      );

      expect(result, '\x1B[31m\x1B[0m');
    });

    test('preserves blank lines in the middle of the message', () {
      final result = formatConsoleMessage(
        message: 'line1\n\nline3',
        colorSchema: '\x1B[31m',
        useColors: true,
      );

      expect(
        result,
        '\x1B[31mline1\x1B[0m\n\x1B[31m\x1B[0m\n\x1B[31mline3\x1B[0m',
      );
    });

    test('supports a custom reset schema', () {
      final result = formatConsoleMessage(
        message: 'hello',
        colorSchema: '\x1B[31m',
        useColors: true,
        resetSchema: '\x1B[39m',
      );

      expect(result, '\x1B[31mhello\x1B[39m');
    });
  });
}
