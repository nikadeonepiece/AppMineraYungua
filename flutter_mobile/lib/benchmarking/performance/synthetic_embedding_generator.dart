import 'dart:math' as math;

import '../../biometric/matching/local_face_candidate.dart';

class SyntheticEmbeddingGenerator {
  SyntheticEmbeddingGenerator({int? seed}) : _rnd = math.Random(seed);

  final math.Random _rnd;
  static const int vectorSize = 192;

  List<LocalFaceCandidate> generate({
    required int totalEmbeddings,
    required int employeeCount,
    required int embeddingsPerEmployee,
  }) {
    final result = <LocalFaceCandidate>[];
    final safeEmbeddingsPerEmployee = embeddingsPerEmployee <= 0 ? 1 : embeddingsPerEmployee;

    final centroids = List.generate(employeeCount, (_) => _normalized(_randomVector()));
    var globalCount = 0;
    for (var emp = 0; emp < employeeCount; emp++) {
      final centroid = centroids[emp];
      for (var j = 0; j < safeEmbeddingsPerEmployee; j++) {
        if (globalCount >= totalEmbeddings) break;
        final noiseScale = 0.035 + (j % 4) * 0.01;
        final noisy = _applyNoise(centroid, noiseScale);
        result.add(
          LocalFaceCandidate(
            empleadoId: emp + 1,
            displayName: 'Empleado ${emp + 1}',
            embedding: _normalized(noisy),
          ),
        );
        globalCount++;
      }
      if (globalCount >= totalEmbeddings) break;
    }
    return result;
  }

  List<double> queryFromEmployee(List<LocalFaceCandidate> all, int employeeId) {
    final candidates = all.where((e) => e.empleadoId == employeeId).toList();
    if (candidates.isEmpty) return _normalized(_randomVector());
    final base = candidates[_rnd.nextInt(candidates.length)].embedding;
    return _normalized(_applyNoise(base, 0.025));
  }

  List<double> _randomVector() {
    return List<double>.generate(
      vectorSize,
      (_) => (_rnd.nextDouble() * 2) - 1,
      growable: false,
    );
  }

  List<double> _applyNoise(List<double> base, double stdDev) {
    return List<double>.generate(
      base.length,
      (i) => base[i] + _gaussian(0, stdDev),
      growable: false,
    );
  }

  List<double> _normalized(List<double> v) {
    var sum = 0.0;
    for (final x in v) {
      sum += x * x;
    }
    if (sum <= 0) return v;
    final norm = math.sqrt(sum);
    return List<double>.generate(v.length, (i) => v[i] / norm, growable: false);
  }

  double _gaussian(double mean, double stdDev) {
    final u1 = 1.0 - _rnd.nextDouble();
    final u2 = 1.0 - _rnd.nextDouble();
    final randStdNormal = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return mean + stdDev * randStdNormal;
  }
}
