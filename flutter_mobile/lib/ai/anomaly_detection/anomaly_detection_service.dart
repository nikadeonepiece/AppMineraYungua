class AnomalyResult {
  AnomalyResult({
    required this.riskScore,
    required this.suspicious,
    required this.reason,
  });

  final double riskScore;
  final bool suspicious;
  final String reason;
}

class AnomalyDetectionService {
  int _recentFailures = 0;
  int _recentSuccess = 0;

  void registerSuccess() {
    _recentSuccess++;
    _recentFailures = (_recentFailures - 1).clamp(0, 9999);
  }

  void registerFailure() {
    _recentFailures++;
  }

  AnomalyResult evaluate({
    required double similarityScore,
    required double qualityScore,
    required bool lowLight,
  }) {
    var risk = 0.0;
    if (similarityScore < 0.62) risk += 0.35;
    if (qualityScore < 0.45) risk += 0.30;
    if (lowLight) risk += 0.15;

    final failurePressure = (_recentFailures / (_recentSuccess + 1)).clamp(0.0, 1.0);
    risk += 0.20 * failurePressure;

    final suspicious = risk >= 0.65;
    final reason = suspicious
        ? 'Patron anomalo: baja similitud/calidad o fallos repetidos'
        : 'Patron normal';

    return AnomalyResult(
      riskScore: risk.clamp(0.0, 1.0),
      suspicious: suspicious,
      reason: reason,
    );
  }
}

