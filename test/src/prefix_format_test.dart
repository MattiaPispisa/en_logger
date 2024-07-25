import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrefixFormat',
    () {
      test(
        'should copyWith',
        () {
          var format = const PrefixFormat(
            startFormat: '[',
            endFormat: ']',
            style: PrefixStyle.pascalCase,
          );

          format = format.copyWith(startFormat: '{');

          expect(format.startFormat, '{');
          expect(format.endFormat, ']');
          expect(format.style, PrefixStyle.pascalCase);

          format =
              format.copyWith(style: PrefixStyle.snakeCase, endFormat: '}');

          expect(format.startFormat, '{');
          expect(format.endFormat, '}');
          expect(format.style, PrefixStyle.snakeCase);
        },
      );
    },
  );
}
