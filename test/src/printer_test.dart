import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrinterHandler',
    () {
      var message = '';
      late EnLoggerHandler handler;

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
    },
  );
}
