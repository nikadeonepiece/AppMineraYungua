/// Resultado de subir la cola local de marcaciones al servidor.
class MarcacionesUploadResult {
  const MarcacionesUploadResult({
    required this.synced,
    required this.attempted,
    this.lastErrorMessage,
    this.transientDeferred = 0,
    this.permanentFailures = 0,
  });

  final int synced;

  /// Envíos HTTP intentados (tras preparar el payload).
  final int attempted;

  /// Último mensaje útil del servidor o error local (ej. empleado sin UUID).
  final String? lastErrorMessage;

  /// Marcaciones aplazadas por error transitorio (siguen como pendientes con backoff).
  final int transientDeferred;

  /// Incrementos de reintento por error considerado permanente (4xx de negocio, etc.).
  final int permanentFailures;
}
