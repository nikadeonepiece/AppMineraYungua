/// Mismo criterio que en repositorios de sync (UUID → int estable).
int stableLocalIdFromRemote(dynamic raw) {
  if (raw is num) return raw.toInt();
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty) return 0;
  final asNum = int.tryParse(text);
  if (asNum != null) return asNum;
  return _fnv1a32(text);
}

int _fnv1a32(String input) {
  var hash = 0x811C9DC5;
  for (final c in input.codeUnits) {
    hash ^= c;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
