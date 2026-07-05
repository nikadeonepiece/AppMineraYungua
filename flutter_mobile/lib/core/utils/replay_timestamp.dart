/// Normaliza a ISO 8601 UTC con precisión de milisegundos, igual que
/// `new Date(iso).toISOString()` en JavaScript (sin microsegundos extra).
/// Evita que el hash offline diverja del validador del backend.
String marcacionFechaUtcIsoForReplay(DateTime dt) {
  final u = dt.toUtc();
  final truncated = DateTime.utc(
    u.year,
    u.month,
    u.day,
    u.hour,
    u.minute,
    u.second,
    u.millisecond,
  );
  return truncated.toIso8601String();
}
