## [2.1.0] - 2026-10-04

### Added

- `EnLogger(onError: ...)`: optional callback invoked when a handler (`write` or `can`) or a lazy message/data provider throws. Shared with the instances created with `getConfiguredInstance`.
- `PrintLogHandler`: a console log handler that writes with `print`. Useful for CLI tools, scripts, and tests. Shares the same color system and message filters as `DevLogHandler`.

### Fixed

- A handler or a lazy provider throwing no longer stops the logger: previously every following log was silently dropped, for all handlers. Now each handler is isolated: a failing handler doesn't prevent the other handlers, nor the following logs, from being written.
- `EnLogger` now works on Web: `Isolate.current` is no longer accessed on platforms without `dart:isolate` (it threw `Unsupported operation: Isolate.current` on every log). `isolateName` is `null` there.
- `DevLogHandler` now colors every line of a multi-line message, instead of only coloring the first line in consoles that render each line as a separate event (e.g. a browser's expanded console view).
- ANSI color codes are now only emitted when the current environment is detected to support them (or when `useColors: true` is explicitly set). Previously, colors were always emitted, which could leak raw ANSI escape codes into consoles that don't interpret them.

## [2.0.0] - 2026-05-28

### Added

- **BREAKING:** `Handler.write` now receives additional parameters: `error`, `tags`, `eventId`, `timestamp`, and `sequenceNumber`.
- **Core Observability Enhancements:** Every log event now automatically generates and forwards the following to the `Handler`:
  - A unique `eventId`.
  - A `callerInfo`, where the user call the log method
  - A `isolateName`, the `debugName` of the isolate where the log method is executed
  - A `timestamp`, captured immediately before any async queueing or lazy processing.
  - A globally incrementing `sequenceNumber` to guarantee the absolute chronological creation order of the logs.
- **Error Disambiguation:** Separated the `error` object from the text `message` for logs with a severity of `error` or higher by introducing a dedicated `error` property.
- **Tags:** Added `tags`, an optional map of additional encodable key-value pairs to attach to log messages.
- **Zone Context Extraction:** Added `zoneContextKeys`. `EnLogger` can now automatically extract specified keys from the current `Zone`, merge them with method-specific `tags`, and forward the unified map to the `Handler`.

### Changed

- **Breaking**: Rename ~~PrinterHandler~~ to `DevLogHandler`, ~~PrinterColorConfiguration~~ to `DevLogColorConfiguration`, ~~PrinterColor~~ to `DevLogColor`
- Preserve logs order (fifo) when lazy methods are used 


## [1.3.0] - 2026-02-24

### Added

- Added `lazy` behavior to `EnLogger`
- Added `dispose` and `close` methods to `EnLogger`

### Changed

- chore: improved documentation (README and code documentation)

## [1.2.1] - 2026-01-17

### Changed

- chore: Improved documentation

## [1.2.0] - 2025-02-09

### Added

- new `PrefixFormat` constructor: `PrefixFormat-snakeSquare`

### Changed

- Added default prefixFormat on `PrinterHandler`
- chore: Improved example, readme
- chore: More tests

## [1.1.1] - 2024-07-25

### Fix

- chore: Documented new public api

## [1.1.0] - 2024-07-25

### Added

- test for 100% coverage

## [1.0.1] - 2024-07-20

### Fixed

- fixed `PrinterHandler.write`

## [1.0.0] - 2024-07-20

### First release

- EnLogger
- PrinterHandler