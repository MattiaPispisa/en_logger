import 'dart:isolate';

/// The debug name of the current isolate.
///
/// Delegates to `dart:isolate`'s `Isolate.current.debugName`.
String? get currentIsolateName => Isolate.current.debugName;
