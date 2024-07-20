import 'package:en_logger/en_logger.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    'PrefixStyle',
    () {
      test(
        'should apply pascalCase style',
        () {
          expect(PrefixStyle.pascalCase.applyOn('my text'), 'MyText');
          expect(PrefixStyle.pascalCase.applyOn('MyText'), 'Mytext');
          expect(PrefixStyle.pascalCase.applyOn('my_text'), 'MyText');
          expect(PrefixStyle.pascalCase.applyOn('my text 1'), 'MyText1');
        },
      );

      test(
        'should apply snakeCase style',
        () {
          expect(PrefixStyle.snakeCase.applyOn('my text'), 'my_text');
          expect(PrefixStyle.snakeCase.applyOn('MyText'), 'my_text');
          expect(PrefixStyle.snakeCase.applyOn('my_text'), 'my_text');
          expect(PrefixStyle.snakeCase.applyOn('my text 1'), 'my_text_1');
        },
      );

      test(
        'should apply uppercaseSnakeCase style',
        () {
          expect(PrefixStyle.uppercaseSnakeCase.applyOn('my text'), 'MY_TEXT');
          expect(PrefixStyle.uppercaseSnakeCase.applyOn('MyText'), 'MY_TEXT');
          expect(PrefixStyle.uppercaseSnakeCase.applyOn('my_text'), 'MY_TEXT');
          expect(
            PrefixStyle.uppercaseSnakeCase.applyOn('my text 1'),
            'MY_TEXT_1',
          );
        },
      );
    },
  );
}
