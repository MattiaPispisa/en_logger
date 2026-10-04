import 'dart:isolate';

import 'package:en_logger/src/isolate/isolate_name.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('currentIsolateName', () {
    test(
      'returns the current isolate debug name',
      () {
        expect(currentIsolateName, Isolate.current.debugName);
      },
      testOn: 'vm',
    );

    test(
      'returns null where isolates are not supported',
      () {
        expect(currentIsolateName, isNull);
      },
      testOn: 'browser',
    );
  });
}
