import 'dart:isolate';

import '../../utils/embedding_math.dart';
import 'local_face_candidate.dart';

class LocalFaceMatcher {
  LocalFaceMatcher({required this.threshold}) : assert(threshold > 0 && threshold <= 1);

  final double threshold;

  LocalFaceMatch? findBestMatch(List<double> queryEmbedding, List<LocalFaceCandidate> candidates) {
    if (queryEmbedding.isEmpty || candidates.isEmpty) return null;

    LocalFaceCandidate? best;
    var bestScore = -1.0;
    for (final candidate in candidates) {
      final score = cosineSimilarity(queryEmbedding, candidate.embedding);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    if (best == null || bestScore < threshold) return null;
    return LocalFaceMatch(candidate: best, score: bestScore);
  }

  Future<LocalFaceMatch?> findBestMatchIsolated(
    List<double> queryEmbedding,
    List<LocalFaceCandidate> candidates,
  ) async {
    return _findBestIsolated(queryEmbedding, candidates, threshold: threshold, applyThreshold: true);
  }

  Future<LocalFaceMatch?> findBestCandidateIsolated(
    List<double> queryEmbedding,
    List<LocalFaceCandidate> candidates,
  ) async {
    return _findBestIsolated(queryEmbedding, candidates, threshold: 0, applyThreshold: false);
  }

  Future<LocalFaceMatch?> _findBestIsolated(
    List<double> queryEmbedding,
    List<LocalFaceCandidate> candidates, {
    required double threshold,
    required bool applyThreshold,
  }) async {
    if (queryEmbedding.isEmpty || candidates.isEmpty) return null;
    final payload = {
      'threshold': threshold,
      'applyThreshold': applyThreshold,
      'query': queryEmbedding,
      'candidates': candidates
          .map(
            (c) => {
              'empleadoId': c.empleadoId,
              'displayName': c.displayName,
              'embedding': c.embedding,
            },
          )
          .toList(growable: false),
    };
    final result = await Isolate.run(() => _matchPayload(payload));
    if (result == null) return null;
    return LocalFaceMatch(
      candidate: LocalFaceCandidate(
        empleadoId: result['empleadoId'] as int,
        displayName: result['displayName'] as String,
        embedding: (result['embedding'] as List).cast<double>(),
      ),
      score: result['score'] as double,
    );
  }

  static Map<String, Object?>? _matchPayload(Map<String, Object?> payload) {
    final query = (payload['query'] as List).cast<double>();
    final threshold = payload['threshold'] as double;
    final applyThreshold = payload['applyThreshold'] as bool? ?? true;
    final candidates = (payload['candidates'] as List)
        .cast<Map<String, Object?>>()
        .toList(growable: false);

    Map<String, Object?>? best;
    var bestScore = -1.0;
    for (final c in candidates) {
      final embedding = (c['embedding'] as List).cast<double>();
      final score = cosineSimilarity(query, embedding);
      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }
    if (best == null) return null;
    if (applyThreshold && bestScore < threshold) return null;
    return {
      ...best,
      'score': bestScore,
    };
  }
}
