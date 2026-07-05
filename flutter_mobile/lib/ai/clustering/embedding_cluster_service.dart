import '../../biometric/matching/local_face_candidate.dart';

class EmbeddingClusterService {
  // Clustering ligero por hash de componentes iniciales para pre-particionar.
  Map<int, List<LocalFaceCandidate>> buildClusters(List<LocalFaceCandidate> candidates) {
    final out = <int, List<LocalFaceCandidate>>{};
    for (final c in candidates) {
      final key = clusterKey(c.embedding);
      out.putIfAbsent(key, () => <LocalFaceCandidate>[]).add(c);
    }
    return out;
  }

  int clusterKey(List<double> embedding) {
    if (embedding.length < 8) return 0;
    var hash = 17;
    for (var i = 0; i < 8; i++) {
      final quant = (embedding[i] * 10).round();
      hash = 31 * hash + quant;
    }
    return hash;
  }

  List<LocalFaceCandidate> candidatesForQuery(
    List<double> query,
    Map<int, List<LocalFaceCandidate>> clusters,
  ) {
    if (clusters.isEmpty) return const [];
    final key = clusterKey(query);
    final exact = clusters[key];
    if (exact != null && exact.isNotEmpty) return exact;
    return clusters.values.expand((e) => e).toList(growable: false);
  }
}

