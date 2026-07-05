import 'network_exception.dart';

/// Errores de subida de cola offline: reintento con backoff vs revisión humana.
enum OfflineSyncErrorKind {
  /// Red caída, timeout, 5xx, 429, etc.
  transient,

  /// Firma, empleado, permisos: reintentar igual no suele arreglar sin cambio de datos o sesión.
  permanent,

  desconocido,
}

class SyncErrorClassifier {
  const SyncErrorClassifier._();

  static OfflineSyncErrorKind classify(Object error) {
    if (error is NetworkException) {
      return classifyNetwork(error);
    }
    return OfflineSyncErrorKind.transient;
  }

  static OfflineSyncErrorKind classifyNetwork(NetworkException e) {
    final c = e.statusCode;
    if (c == null) {
      return OfflineSyncErrorKind.transient;
    }
    if (c == 408 || c == 429 || c == 500 || c == 502 || c == 503 || c == 504) {
      return OfflineSyncErrorKind.transient;
    }
    if (c == 401 || c == 403 || c == 404 || c == 400 || c == 422) {
      return OfflineSyncErrorKind.permanent;
    }
    if (c >= 500) {
      return OfflineSyncErrorKind.transient;
    }
    if (c >= 400) {
      return OfflineSyncErrorKind.permanent;
    }
    return OfflineSyncErrorKind.desconocido;
  }

  /// Backoff exponencial acotado (segundos desde ahora).
  static DateTime transientBackoffUntil(int intentosPrevios) {
    final exp = intentosPrevios.clamp(0, 8);
    final seconds = (20 * (1 << exp)).clamp(20, 900);
    return DateTime.now().add(Duration(seconds: seconds));
  }

  static String truncateMessage(String? raw, {int maxLen = 220}) {
    final t = raw?.trim() ?? '';
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen)}…';
  }
}
