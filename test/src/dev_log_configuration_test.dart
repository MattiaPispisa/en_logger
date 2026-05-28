import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrinterColorConfiguration',
    () {
      test('should configure color for severities', () {
        final config = DevLogColorConfiguration()
          ..setSeverityColor(
            Severity.emergency,
            const DevLogColor.magenta(),
          )
          ..setSeverityColors(
            const {
              Severity.informational: DevLogColor.red(),
            },
          );

        expect(
          config.getColor(Severity.emergency).schema,
          const DevLogColor.magenta().schema,
        );
        expect(
          config.getColor(Severity.informational).schema,
          const DevLogColor.red().schema,
        );
      });
    },
  );
}
