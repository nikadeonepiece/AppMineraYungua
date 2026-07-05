class LocalFaceCandidate {
  LocalFaceCandidate({
    required this.empleadoId,
    required this.displayName,
    required this.embedding,
  });

  final int empleadoId;
  final String displayName;
  final List<double> embedding;
}

class LocalFaceMatch {
  LocalFaceMatch({
    required this.candidate,
    required this.score,
  });

  final LocalFaceCandidate candidate;
  final double score;
}
