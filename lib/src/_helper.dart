part of 'en_logger.dart';

Map<String, Object?> _sanitizeTags(Map<String, Object?> rawData) {
  final cleanMap = <String, Object?>{};

  for (final entry in rawData.entries) {
    final value = entry.value;

    if (_isValidTagValue(value)) {
      cleanMap[entry.key] = value;
    } else if (value is Iterable) {
      cleanMap[entry.key] =
          value.map((e) => _isValidTagValue(e) ? e : e.toString()).toList();
    } else {
      cleanMap[entry.key] = value.toString();
    }
  }

  return cleanMap;
}

bool _isValidTagValue(Object? value) {
  return value == null || value is num || value is String || value is bool;
}

String _generateUuidV4() {
  final random = math.Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));

  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();

  return '${hex.sublist(0, 4).join()}-'
      '${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-'
      '${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10, 16).join()}';
}

final _symbolRegex = RegExp(r'Symbol\("(.+)"\)');

extension _SymbolHelper on Symbol {
  String get name {
    final match = _symbolRegex.firstMatch(toString());
    return match?.group(1) ?? toString();
  }
}
