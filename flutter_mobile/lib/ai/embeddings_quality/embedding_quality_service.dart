import 'dart:math' as math;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class EmbeddingQualityScore {
  EmbeddingQualityScore({
    required this.faceScore,
    required this.embeddingScore,
    required this.finalScore,
  });

  final double faceScore;
  final double embeddingScore;
  final double finalScore;
}

class EmbeddingQualityService {
  EmbeddingQualityScore evaluate({
    required Face face,
    required List<double> embedding,
    required int frameWidth,
    required int frameHeight,
  }) {
    final box = face.boundingBox;
    final faceArea = (box.width * box.height).abs();
    final frameArea = math.max(1.0, frameWidth * frameHeight.toDouble());
    final areaRatio = (faceArea / frameArea).clamp(0.0, 1.0);

    final yaw = (face.headEulerAngleY ?? 0).abs();
    final pitch = (face.headEulerAngleX ?? 0).abs();
    final posePenalty = ((yaw + pitch) / 90.0).clamp(0.0, 0.8);

    final left = face.leftEyeOpenProbability ?? 0.5;
    final right = face.rightEyeOpenProbability ?? 0.5;
    final eyes = ((left + right) / 2).clamp(0.0, 1.0);

    final faceScore = (0.55 * areaRatio + 0.35 * eyes + 0.10 * (1 - posePenalty)).clamp(0.0, 1.0);

    var l2 = 0.0;
    for (final v in embedding) {
      l2 += v * v;
    }
    final normScore = (1.0 - (1.0 - math.sqrt(l2)).abs()).clamp(0.0, 1.0);
    final variance = _variance(embedding).clamp(0.0, 1.0);
    final embeddingScore = (0.65 * normScore + 0.35 * variance).clamp(0.0, 1.0);

    final finalScore = (0.6 * faceScore + 0.4 * embeddingScore).clamp(0.0, 1.0);
    return EmbeddingQualityScore(
      faceScore: faceScore,
      embeddingScore: embeddingScore,
      finalScore: finalScore,
    );
  }

  double _variance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    var acc = 0.0;
    for (final v in values) {
      final d = v - mean;
      acc += d * d;
    }
    return (acc / values.length).clamp(0.0, 1.0);
  }
}

