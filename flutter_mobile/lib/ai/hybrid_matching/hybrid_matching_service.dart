import '../../biometric/matching/local_face_candidate.dart';

typedef CloudValidationFn = Future<bool> Function({
  required int empleadoId,
  required double localScore,
});

class HybridMatchDecision {
  HybridMatchDecision({
    required this.accepted,
    required this.usedCloudValidation,
  });

  final bool accepted;
  final bool usedCloudValidation;
}

class HybridMatchingService {
  HybridMatchingService({
    this.cloudValidationFn,
    this.cloudValidationEnabled = false,
    this.cloudValidationMinScore = 0.70,
  });

  final CloudValidationFn? cloudValidationFn;
  final bool cloudValidationEnabled;
  final double cloudValidationMinScore;

  Future<HybridMatchDecision> decide({
    required LocalFaceMatch match,
    required double requiredThreshold,
    required bool forceOffline,
  }) async {
    final localAccepted = match.score >= requiredThreshold;
    if (forceOffline || !cloudValidationEnabled || cloudValidationFn == null) {
      return HybridMatchDecision(accepted: localAccepted, usedCloudValidation: false);
    }
    if (localAccepted || match.score < cloudValidationMinScore) {
      return HybridMatchDecision(accepted: localAccepted, usedCloudValidation: false);
    }
    final cloudAccepted = await cloudValidationFn!(
      empleadoId: match.candidate.empleadoId,
      localScore: match.score,
    );
    return HybridMatchDecision(accepted: cloudAccepted, usedCloudValidation: true);
  }
}

