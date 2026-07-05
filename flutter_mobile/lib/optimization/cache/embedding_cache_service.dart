import '../../biometric/matching/local_face_candidate.dart';

class EmbeddingCacheService {
  EmbeddingCacheService({
    this.ttl = const Duration(minutes: 3),
  });

  /// Caché compartida del catálogo en memoria (matching local / pantallas).
  /// Permite invalidar desde sync u otros puntos sin acoplar a un widget concreto.
  static final EmbeddingCacheService shared = EmbeddingCacheService();

  final Duration ttl;
  List<LocalFaceCandidate>? _cached;
  DateTime? _expiresAt;

  List<LocalFaceCandidate>? get() {
    final expires = _expiresAt;
    final cached = _cached;
    if (expires == null || cached == null) return null;
    if (DateTime.now().isAfter(expires)) {
      _cached = null;
      _expiresAt = null;
      return null;
    }
    return cached;
  }

  void set(List<LocalFaceCandidate> items) {
    _cached = items;
    _expiresAt = DateTime.now().add(ttl);
  }

  void invalidate() {
    _cached = null;
    _expiresAt = null;
  }
}
