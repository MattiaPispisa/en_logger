import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrinterColorConfiguration',
    () {
      test('should configure color for severities', () {
        final config = PrinterColorConfiguration()
          ..setSeverityColor(
            Severity.emergency,
            const PrinterColor.magenta(),
          )
          ..setSeverityColors(
            const {
              Severity.informational: PrinterColor.red(),
            },
          );

        expect(
          config.getColor(Severity.emergency).schema,
          const PrinterColor.magenta().schema,
        );
        expect(
          config.getColor(Severity.informational).schema,
          const PrinterColor.red().schema,
        );
      });
    },
  );
}
