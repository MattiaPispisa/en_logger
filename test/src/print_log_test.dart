import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrintLogHandler',
    () {
      var message = '';
      late PrintLogHandler handler;

      setUp(() {
        handler = PrintLogHandler.custom(
          printCallback: (Object? content) {
            message = content.toString();
          },
          prefixFormat: const PrefixFormat(
            endFormat: ']',
            startFormat: '[',
          ),
          useColors: true,
        );
      });

      test(
        'should create correctly',
        () {
          expect(
            () {
              PrintLogHandler();
            },
            returnsNormally,
          );
        },
      );

      test(
        'should write message correctly',
        () {
          handler.write(
            'error',
            severity: Severity.error,
            timestamp: DateTime(2025),
            eventId: 'id',
            tags: {},
            sequenceNumber: 0,
          );

          expect(message, '${const DevLogColor.red().schema}error\x1B[0m');
        },
      );

      test(
        'should write message with prefix correctly',
        () {
          handler.write(
            'error',
            severity: Severity.error,
            prefix: 'Prefix',
            timestamp: DateTime(2025),
            eventId: 'id',
            tags: {},
            sequenceNumber: 0,
          );

          expect(
            message,
            '${const DevLogColor.red().schema}[PREFIX] error\x1B[0m',
          );
        },
      );

      test(
        'should write message with prefix with default prefix format',
        () {
          handler = PrintLogHandler.custom(
            printCallback: (Object? content) {
              message = content.toString();
            },
            useColors: true,
          )..write(
              'error',
              severity: Severity.error,
              prefix: 'Prefix',
              timestamp: DateTime(2025),
              eventId: 'id',
              tags: {},
              sequenceNumber: 0,
            );

          expect(
            message,
            '${const DevLogColor.red().schema}[PREFIX] error\x1B[0m',
          );
        },
      );

      test('should configure colors', () {
        handler
          ..configure({
            Severity.informational: const DevLogColor.magenta(),
            Severity.debug: const DevLogColor.custom(schema: '\x1B[38m'),
          })
          ..write(
            'informational',
            severity: Severity.informational,
            timestamp: DateTime(2025),
            eventId: 'id',
            tags: {},
            sequenceNumber: 0,
          );

        expect(
          message,
          '${const DevLogColor.magenta().schema}informational\x1B[0m',
        );

        handler.write(
          'debug',
          severity: Severity.debug,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );
        expect(
          message,
          '\x1B[38mdebug\x1B[0m',
        );
      });

      test('should color every line of a multi-line message', () {
        handler.write(
          'line1\nline2',
          severity: Severity.error,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );

        expect(
          message,
          '${const DevLogColor.red().schema}line1\x1B[0m\n'
          '${const DevLogColor.red().schema}line2\x1B[0m',
        );
      });

      test('should not emit ANSI codes when useColors is false', () {
        handler = PrintLogHandler.custom(
          printCallback: (Object? content) {
            message = content.toString();
          },
          prefixFormat: const PrefixFormat(endFormat: ']', startFormat: '['),
          useColors: false,
        )..write(
            'line1\nline2',
            severity: Severity.error,
            prefix: 'Prefix',
            timestamp: DateTime(2025),
            eventId: 'id',
            tags: {},
            sequenceNumber: 0,
          );

        expect(message, '[PREFIX] line1\nline2');
      });

      test('should append error to the message', () {
        handler.write(
          'oops',
          severity: Severity.error,
          error: 'boom',
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );

        expect(
          message,
          '${const DevLogColor.red().schema}oops\x1B[0m\n'
          '${const DevLogColor.red().schema}Error: boom\x1B[0m',
        );
      });

      test('should append the stack trace to the message', () {
        final stackTrace = StackTrace.fromString('#0 main');

        handler.write(
          'oops',
          severity: Severity.error,
          stackTrace: stackTrace,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );

        expect(
          message,
          '${const DevLogColor.red().schema}oops\x1B[0m\n'
          '${const DevLogColor.red().schema}#0 main\x1B[0m',
        );
      });

      test('should filter messages', () {
        handler = PrintLogHandler.custom(
          printCallback: (Object? content) {
            message = content.toString();
          },
          writeIfContains: ['must be present', 'can be present'],
          writeIfNotContains: ['hide', 'remove'],
          useColors: true,
        )..write(
            'must be present some text',
            severity: Severity.debug,
            timestamp: DateTime(2025),
            eventId: 'id',
            tags: {},
            sequenceNumber: 0,
          );

        expect(
          message.contains('must be present some text'),
          true,
        );

        handler.write(
          'must be present the remove word',
          severity: Severity.debug,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );
        expect(
          message.contains('must be present the remove word'),
          false,
        );

        handler.write(
          'must be present the hide word',
          severity: Severity.debug,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );
        expect(
          message.contains('must be present the hide word'),
          false,
        );

        handler.write(
          'can be present this text',
          severity: Severity.debug,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );
        expect(
          message.contains('can be present this text'),
          true,
        );

        handler.write(
          'some words',
          severity: Severity.debug,
          timestamp: DateTime(2025),
          eventId: 'id',
          tags: {},
          sequenceNumber: 0,
        );
        expect(
          message.contains('some words'),
          false,
        );
      });
    },
  );
}
