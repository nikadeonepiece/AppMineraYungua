class AiMetricsSnapshot {
  AiMetricsSnapshot({
    required this.totalAttempts,
    required this.totalAccepted,
    required this.totalRejected,
    required this.falseAcceptProxy,
    required this.falseRejectProxy,
  });

  final int totalAttempts;
  final int totalAccepted;
  final int totalRejected;
  final double falseAcceptProxy;
  final double falseRejectProxy;
}

class AiMetricsService {
  int _attempts = 0;
  int _accepted = 0;
  int _rejected = 0;
  int _lowScoreAccepted = 0;
  int _highScoreRejected = 0;

  void registerAttempt({
    required bool accepted,
    required double similarityScore,
    required double threshold,
  }) {
    _attempts++;
    if (accepted) {
      _accepted++;
      if (similarityScore < threshold + 0.03) {
        _lowScoreAccepted++;
      }
    } else {
      _rejected++;
      if (similarityScore > threshold + 0.08) {
        _highScoreRejected++;
      }
    }
  }

  AiMetricsSnapshot snapshot() {
    final attempts = _attempts == 0 ? 1 : _attempts;
    return AiMetricsSnapshot(
      totalAttempts: _attempts,
      totalAccepted: _accepted,
      totalRejected: _rejected,
      falseAcceptProxy: _lowScoreAccepted / attempts,
      falseRejectProxy: _highScoreRejected / attempts,
    );
  }
}

