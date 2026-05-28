## [2.0.0]

### Added

- **BREAKING:** `Handler.write` now receives additional parameters: `error`, `tags`, `eventId`, `timestamp`, and `sequenceNumber`.
- **Core Observability Enhancements:** Every log event now automatically generates and forwards the following to the `Handler`:
  - A unique `eventId`.
  - A `timestamp`, captured immediately before any async queueing or lazy processing.
  - A globally incrementing `sequenceNumber` to guarantee the absolute chronological creation order of the logs.
- **Error Disambiguation:** Separated the `error` object from the text `message` for logs with a severity of `error` or higher by introducing a dedicated `error` property.
- **Tags:** Added `tags`, an optional map of additional encodable key-value pairs to attach to log messages.
- **Zone Context Extraction:** Added `zoneContextKeys`. `EnLogger` can now automatically extract specified keys from the current `Zone`, merge them with method-specific `tags`, and forward the unified map to the `Handler`.

### Changed

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