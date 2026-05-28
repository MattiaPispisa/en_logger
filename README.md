# En Logger

[![package badge][package_badge]][pub_link]
[![pub points][pub_points_badge]][pub_link]
[![pub likes][pub_likes_badge]][pub_link]
[![codecov][codecov_badge]][codecov_link]
[![ci badge][ci_badge]][ci_link]
[![license][license_badge]][license_link]
[![pub publisher][pub_publisher_badge]][pub_publisher_link]

Welcome to **EnLogger**—a highly flexible and extensible logging system designed to adapt to your application's unique needs. 

Instead of restricting you to the standard debug console, `EnLogger` acts as a central hub. It broadcasts your log messages to a customizable list of `EnLoggerHandler`s. You simply log your message once, and let your attached handlers decide where and how that data is processed.

**Key Features:**

* **Plug-and-Play Architecture:** **Log once, write anywhere**. You can easily implement custom handlers based on your specific requirements:
  * *Need local persistence?* Implement a handler that writes logs to a local file.
  * *Need remote crash reporting?* Create a handler that pipes messages directly to Sentry, Crashlytics, or Datadog.
* **Lazy Evaluation:** Boost your app's performance with "lazy" logging. Wrap expensive string interpolations or data serializations in closures; if the log level is disabled, the computation is completely skipped (see the [Lazy messages](#lazy-messages) section for details).
* **Zone:** Automatically extract contextual data (tags) from `Zone.current` and attach them to every log event.
* **Syslog Standards:** All log operations strictly adhere to the standard syslog severity levels (Emergency, Alert, Critical, Error, Warning, Notice, Info, Debug).
* **Ready-to-use Console Logger:** Get started immediately with the included `PrinterHandler`, which outputs beautifully colored and formatted messages straight to your developer console.

To see these features in action, check out the [example project](./example/main.dart).

- [En Logger](#en-logger)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [Fast setup](#fast-setup)
    - [Prefix](#prefix)
    - [Data](#data)
    - [Instances](#instances)
    - [Lazy messages](#lazy-messages)
    - [Closing the logger](#closing-the-logger)
    - [PrinterHandler](#printerhandler)
    - [CustomHandler](#customhandler)


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

### Lazy messages

Lazy messages are not evaluated until at least one handler is going to write them.
Use them to avoid expensive computations when a log level is disabled (e.g. in production, where debug is often turned off).

The message closure is only called when at least one handler returns `true` from `can(severity)` for that log.

```dart
logger.lazyDebug(() => 'a lazy debug message');
// The closure is not run if debug is disabled (every handler's `can` returns `false`)
```

By default, `can` returns `true` for every handler, so all log levels are written unless you override it.

The message callbacks (e.g. the closure passed to `lazyDebug`) may be asynchronous. Handle exceptions inside the callback, otherwise they are ignored.

### Tags & Zones
EnLogger can automatically extract contextual data (tags) from Dart's [Zone.current] and attach them to every log event.
By providing `zoneContextKeys` to the constructor, the logger will capture only the specified keys from the current execution zone.

Additionally, every logging method accepts its own `tags` parameter. The handlers will receive a single, merged, and sanitized map containing both the requested zone tags and the method-specific tags.


```dart
final logger = EnLogger(
   zoneContextKeys: {#userId},
   ...
);

runZoned(
   () {
     // In addition to the method tags, the zoneContextKeys 
     // values will be extracted from the zones
     logger
       .debug('a debug message',
          prefix: 'API Repository',
          tags: {'custom_key':'custom_value'},
          );
   },
  zoneValues: {
    #userId: 123,
    #tenantId: 'abc'
  },
 );
```

### Closing the logger

When you are done using an `EnLogger` instance, you should clean up its resources. `EnLogger` provides a graceful shutdown mechanism that safely stops accepting new logs and **waits for any pending asynchronous writes or lazy evaluations to finish** before clearing its handlers, ensuring no data is lost.

You can trigger this shutdown using two methods depending on your architectural needs:

* **`close()`**: The preferred, asynchronous method. You can `await` it to guarantee all pending logs have been fully processed and written before proceeding.
* **`dispose()`**: A synchronous wrapper around `close()`. It immediately marks the logger as closed and handles the graceful shutdown in the background (fire-and-forget).

*Note: Both methods are safe to call multiple times (idempotent) and automatically cascade the shutdown to any child instances created via `getConfiguredInstance()`.*

```dart
// Asynchronous (Graceful Shutdown)
await logger.close();

// Synchronous (e.g., inside Flutter lifecycle)
@override
void dispose() {
  logger.dispose();
  super.dispose();
}
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

2. Override `write` method with your custom write operation.

```dart
class FileHandler extends EnLoggerHandler {
  @override
  void write(String message) {
    _logToFile(message);
  }
}
```

3. Override `can` method to filter logs to complete skip the log evaluation.
```dart
@override
bool can({required Severity severity, String? prefix}) {
  if (isProduction) {
    return severity.atLeastError; // only error and above are evaluated and written
  }
  return true; // every log is evaluated and written (default behavior)
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
