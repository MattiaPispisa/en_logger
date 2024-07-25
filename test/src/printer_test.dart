import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrinterHandler',
    () {
      var message = '';
      late PrinterHandler handler;

      setUp(() {
        handler = PrinterHandler.custom(
          logCallback: (
            String content, {
            DateTime? time,
            int? sequenceNumber,
            int level = 0,
            String name = '',
            Zone? zone,
            Object? error,
            StackTrace? stackTrace,
          }) {
            message = content;
          },
          prefixFormat: const PrefixFormat(
            endFormat: ']',
            startFormat: '[',
          ),
        );
      });

      test(
        'should create correctly',
        () {
          expect(() {
            PrinterHandler();
          }, returnsNormally);
        },
      );

      test(
        'should write message correctly',
        () {
          handler.write('error', severity: Severity.error);

          expect(message, '${const PrinterColor.red().schema}error\x1B[0m');
        },
      );

      test(
        'should write message with prefix correctly',
        () {
          handler.write('error', severity: Severity.error, prefix: 'Prefix');

          expect(
            message,
            '${const PrinterColor.red().schema}[PREFIX] error\x1B[0m',
          );
        },
      );

      test('should configure colors', () {
        handler
          ..configure({
            Severity.informational: const PrinterColor.magenta(),
            Severity.debug: const PrinterColor.custom(schema: '\x1B[38m'),
          })
          ..write(
            'informational',
            severity: Severity.informational,
          );

        expect(
          message,
          '${const PrinterColor.magenta().schema}informational\x1B[0m',
        );

        handler.write('debug', severity: Severity.debug);
        expect(
          message,
          '\x1B[38mdebug\x1B[0m',
        );
      });

      test('should filter messages', () {
        handler = PrinterHandler.custom(
          logCallback: (
            String content, {
            DateTime? time,
            int? sequenceNumber,
            int level = 0,
            String name = '',
            Zone? zone,
            Object? error,
            StackTrace? stackTrace,
          }) {
            message = content;
          },
          writeIfContains: ['must be present', 'can be present'],
          writeIfNotContains: ['hide', 'remove'],
        )..write('must be present some text', severity: Severity.debug);

        expect(
          message.contains('must be present some text'),
          true,
        );

        handler.write(
          'must be present the remove word',
          severity: Severity.debug,
        );
        expect(
          message.contains('must be present the remove word'),
          false,
        );

        handler.write(
          'must be present the hide word',
          severity: Severity.debug,
        );
        expect(
          message.contains('must be present the hide word'),
          false,
        );

        handler.write(
          'can be present this text',
          severity: Severity.debug,
        );
        expect(
          message.contains('can be present this text'),
          true,
        );

        handler.write(
          'some words',
          severity: Severity.debug,
        );
        expect(
          message.contains('some words'),
          false,
        );
      });
    },
  );
}
