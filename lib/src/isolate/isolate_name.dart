import 'package:en_logger/src/isolate/isolate_name_stub.dart'
    if (dart.library.isolate) 'package:en_logger/src/isolate/isolate_name_vm.dart'
    as platform;

/// The debug name of the current isolate.
///
/// Uses `dart:isolate`'s `Isolate.current.debugName` when available, and
/// falls back to `null` on platforms where `dart:isolate` is not supported
/// (e.g. Web), where accessing `Isolate.current` would throw.
String? get currentIsolateName => platform.currentIsolateName;
