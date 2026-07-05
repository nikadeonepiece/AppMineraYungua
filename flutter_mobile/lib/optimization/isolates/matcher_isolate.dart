import '../../biometric/matching/local_face_candidate.dart';
import '../../utils/embedding_math.dart';

class MatcherIsolate {
  static LocalFaceMatch? run(
    List<double> query,
    List<LocalFaceCandidate> candidates,
    double threshold,
  ) {
    if (query.isEmpty || candidates.isEmpty) return null;
    LocalFaceCandidate? best;
    var bestScore = -1.0;
    for (final candidate in candidates) {
      final score = cosineSimilarity(query, candidate.embedding);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    if (best == null || bestScore < threshold) return null;
    return LocalFaceMatch(candidate: best, score: bestScore);
  }
}
