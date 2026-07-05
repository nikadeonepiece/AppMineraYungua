import '../../biometric/matching/local_face_candidate.dart';

class EmbeddingPrefilterIndex {
  List<LocalFaceCandidate> prefilter(
    List<double> query,
    List<LocalFaceCandidate> all, {
    int maxCandidates = 300,
  }) {
    if (all.length <= maxCandidates || query.isEmpty) return all;
    final scored = <({LocalFaceCandidate c, double s})>[];
    for (final c in all) {
      if (c.embedding.isEmpty) continue;
      final s = _quickScore(query, c.embedding);
      scored.add((c: c, s: s));
    }
    scored.sort((a, b) => b.s.compareTo(a.s));
    return scored.take(maxCandidates).map((e) => e.c).toList(growable: false);
  }

  double _quickScore(List<double> a, List<double> b) {
    final len = a.length < b.length ? a.length : b.length;
    if (len == 0) return 0;
    final step = len >= 64 ? len ~/ 64 : 1;
    var dot = 0.0;
    for (var i = 0; i < len; i += step) {
      dot += a[i] * b[i];
    }
    return dot;
  }
}
