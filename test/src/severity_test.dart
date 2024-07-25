import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'severity',
    () {
      test('level', () {
        expect(Severity.emergency.atLeastError, true);
        expect(Severity.alert.atLeastError, true);
        expect(Severity.critical.atLeastError, true);
        expect(Severity.error.atLeastError, true);
        expect(Severity.warning.atLeastError, false);
        expect(Severity.notice.atLeastError, false);
        expect(Severity.informational.atLeastError, false);
        expect(Severity.debug.atLeastError, false);
      });
    },
  );
}
