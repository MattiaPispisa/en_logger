/// Prefix style for formatting prefix text.
///
/// Defines how prefix strings are transformed before being displayed.
enum PrefixStyle {
  /// UPPER_SNAKE_CASE style.
  ///
  /// Converts text to uppercase with underscores separating words.
  ///
  /// Example:
  /// ```dart
  /// PrefixStyle.uppercaseSnakeCase.applyOn('API Repository');
  /// // Returns: 'API_REPOSITORY'
  /// ```
  uppercaseSnakeCase,

  /// snake_case style.
  ///
  /// Converts text to lowercase with underscores separating words.
  ///
  /// Example:
  /// ```dart
  /// PrefixStyle.snakeCase.applyOn('API Repository');
  /// // Returns: 'api_repository'
  /// ```
  snakeCase,

  /// PascalCase style.
  ///
  /// Converts text to PascalCase (first letter of each word capitalized,
  /// no separators).
  ///
  /// Example:
  /// ```dart
  /// PrefixStyle.pascalCase.applyOn('API Repository');
  /// // Returns: 'ApiRepository'
  /// ```
  pascalCase;

  /// Applies this style on [text].
  ///
  /// [text] - The text to format.
  ///
  /// Returns the formatted text according to this style.
  ///
  /// Example:
  /// ```dart
  /// final result = PrefixStyle.uppercaseSnakeCase.applyOn('My Prefix');
  /// // result: 'MY_PREFIX'
  /// ```
  String applyOn(String text) {
    return text.applyStyle(this);
  }
}

extension _StringExt on String {
  String applyStyle(PrefixStyle style) {
    switch (style) {
      case PrefixStyle.pascalCase:
        return toPascalCase();

      case PrefixStyle.snakeCase:
        return toSnakeCase();

      case PrefixStyle.uppercaseSnakeCase:
        return toSnakeCaseUpperCase();
    }
  }

  String toSnakeCase() {
    final result = StringBuffer();
    var isPreviousUnderscore = false;

    for (var i = 0; i < length; i++) {
      final currentChar = this[i];

      if (currentChar == ' ' || currentChar == '_') {
        if (!isPreviousUnderscore) {
          result.write('_');
          isPreviousUnderscore = true;
        }
      } else if (currentChar == currentChar.toUpperCase()) {
        if (i != 0 && !isPreviousUnderscore) {
          result.write('_');
        }
        result.write(currentChar.toLowerCase());
        isPreviousUnderscore = false;
      } else {
        result.write(currentChar);
        isPreviousUnderscore = false;
      }
    }

    return result.toString();
  }

  String toSnakeCaseUpperCase() {
    final result = StringBuffer();
    var isPreviousUnderscore = false;

    for (var i = 0; i < length; i++) {
      final currentChar = this[i];

      if (currentChar == ' ' || currentChar == '_') {
        // Replace spaces and underscores with a single underscore
        if (!isPreviousUnderscore) {
          result.write('_');
          isPreviousUnderscore = true;
        }
      } else if (currentChar == currentChar.toUpperCase()) {
        // Add an underscore before uppercase letters
        // unless it's the first character
        if (i != 0 && !isPreviousUnderscore) {
          result.write('_');
        }
        result.write(currentChar);
        isPreviousUnderscore = false;
      } else {
        // Convert lowercase letters to uppercase
        result.write(currentChar.toUpperCase());
        isPreviousUnderscore = false;
      }
    }

    return result.toString();
  }

  String toPascalCase() {
    final result = StringBuffer();
    var capitalizeNext = true;

    for (var i = 0; i < length; i++) {
      final currentChar = this[i];

      if (currentChar == ' ' || currentChar == '_') {
        // Skip spaces and underscores, and capitalize the next character
        capitalizeNext = true;
      } else if (capitalizeNext) {
        // Capitalize the current character
        result.write(currentChar.toUpperCase());
        capitalizeNext = false;
      } else {
        // Keep lowercase letters and digits as is
        result.write(currentChar.toLowerCase());
      }
    }

    return result.toString();
  }
}
