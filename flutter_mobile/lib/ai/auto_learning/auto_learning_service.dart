class AutoLearningCandidate {
  AutoLearningCandidate({
    required this.empleadoId,
    required this.embedding,
    required this.qualityScore,
    required this.similarityScore,
    required this.createdAt,
  });

  final int empleadoId;
  final List<double> embedding;
  final double qualityScore;
  final double similarityScore;
  final DateTime createdAt;
}

class AutoLearningService {
  final Map<int, List<AutoLearningCandidate>> _pending = {};
  static const int _maxPerEmployee = 15;

  void registerSuccessfulMatch({
    required int empleadoId,
    required List<double> embedding,
    required double qualityScore,
    required double similarityScore,
  }) {
    // Controlado: solo guardamos candidatos de alta calidad para revisión posterior.
    if (qualityScore < 0.70 || similarityScore < 0.80) return;
    final list = _pending.putIfAbsent(empleadoId, () => <AutoLearningCandidate>[]);
    list.add(
      AutoLearningCandidate(
        empleadoId: empleadoId,
        embedding: embedding,
        qualityScore: qualityScore,
        similarityScore: similarityScore,
        createdAt: DateTime.now(),
      ),
    );
    if (list.length > _maxPerEmployee) {
      list.removeRange(0, list.length - _maxPerEmployee);
    }
  }

  List<AutoLearningCandidate> pendingForEmployee(int empleadoId) {
    return List<AutoLearningCandidate>.unmodifiable(_pending[empleadoId] ?? const []);
  }

  Map<int, int> pendingCounts() {
    return {for (final e in _pending.entries) e.key: e.value.length};
  }
}

