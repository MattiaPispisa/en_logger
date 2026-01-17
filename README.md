# En Logger

[![package badge][package_badge]][pub_link]
[![pub points][pub_points_badge]][pub_link]
[![pub likes][pub_likes_badge]][pub_link]
[![codecov][codecov_badge]][codecov_link]
[![ci badge][ci_badge]][ci_link]
[![license][license_badge]][license_link]
[![pub publisher][pub_publisher_badge]][pub_publisher_link]

`EnLogger` allows you to write log messages according to your needs without restricting you to
writing messages to the debug console or other systems. It maintains a list of `EnLoggerHandlers`
internally. You can implement your own EnLoggerHandler based on your specific requirements. Each
time you want to log a message with `EnLogger`, each `EnLoggerHandler` will be invoked to perform
the write operation.

- If you need your system to write logs to a file, implement an EnLoggerHandler that performs the write operation to a file.

- If you want to send logs to Sentry, implement an EnLoggerHandler that maintains an instance of Sentry internally. Each time a log is written, call the write method of Sentry.

`PrinterHandler` is an `EnLoggerHandler` provided within the library that allows you to write
colored messages to the developer console.

Some examples are shown in the [example](./example/main.dart) project.

The logs adhere to the syslog severity levels.

## Installation

```yaml
dependencies:
  en_logger:
```

## Configuration

### Fast setup

- Create en `EnLogger` instance: `final logger = EnLogger()`
- Add handlers to your logger: `logger.addHandler(PrinterLogger())`
- Write log: `logger.debug('Arrived here');`, `logger.error('Error deserializing data')`

### Prefix

Logs can have a prefix. A style can be applied to this prefix.

```dart
final logger = EnLogger(defaultPrefixFormat: PrefixFormat(
    startFormat: '[',
    endFormat: ']',
    style: PrefixStyle.uppercaseSnakeCase,
  ))
  ..addHandler(PrinterLogger())
  ..debug('get data',prefix: "API repository")

  // printer output --> '[API_REPOSITORY] get data'
```

### Data

Messages can include attachments such as serialized data, file contents, and more.

```dart
// error with data
logger.error(
  "error",
  data: [
    EnLoggerData(
      name: "response",
      content: jsonEncode("BE data"),
      description: "serialized BE response",
    ),
  ],
);
```

### Instances

To avoid having to rewrite the prefix each time, you can create instances based on `EnLogger`. For instance, if you have a specific scope (like the API repository), you can instantiate a `EnLogger` with the prefix "API repository," and this prefix will be included in every log unless you explicitly override it.

```dart
final instLogger = logger.getConfiguredInstance(prefix: 'API Repository');
instLogger.debug('a debug message'); // [API Repository] a debug message
instLogger.error(
  'error',
  prefix: 'Custom prefix',
); // [Custom prefix] a debug message
```

### PrinterHandler

A default Develop console handler colored.
There is a basic color setup that can be updated.

```dart
  final printer = PrinterHandler()
    ..configure({Severity.notice: PrinterColor.green()});

```

You can also create custom colors.

```dart
PrinterColor.custom(schema: '\x1B[31m')
```

### CustomHandler

1. Create a custom handler that extends `EnLoggerHandler`;

1. Override `write` method with your custom write operation.

```dart
class FileHandler extends EnLoggerHandler {
  @override
  void write(String message) {
    _logToFile(message);
  }
}
```

Some examples are shown in the [example](./example/main.dart) project.


[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[package_badge]: https://img.shields.io/pub/v/en_logger.svg
[codecov_badge]: https://img.shields.io/codecov/c/github/MattiaPispisa/en_logger/main?logo=codecov
[codecov_link]: https://app.codecov.io/gh/MattiaPispisa/en_logger/tree/main/packages/en_logger
[ci_badge]: https://img.shields.io/github/actions/workflow/status/MattiaPispisa/en_logger/main.yaml
[ci_link]: https://github.com/MattiaPispisa/en_logger/actions/workflows/main.yaml
[pub_points_badge]: https://img.shields.io/pub/points/en_logger
[pub_link]: https://pub.dev/packages/en_logger
[pub_publisher_badge]: https://img.shields.io/pub/publisher/en_logger
[pub_publisher_link]: https://pub.dev/packages?q=publisher%3Amattiapispisa.it
[pub_likes_badge]: https://img.shields.io/pub/likes/en_logger
