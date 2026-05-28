import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrinterHandler',
    () {
      var message = '';
      late DevLogHandler handler;

      setUp(() {
        handler = DevLogHandler.custom(
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
          expect(
            () {
              DevLogHandler();
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
          handler = DevLogHandler.custom(
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

      test('should filter messages', () {
        handler = DevLogHandler.custom(
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
