import '../config/app_config.dart';

class CatalogEntry {
  CatalogEntry({
    required this.empleadoId,
    required this.embedding,
    required this.displayName,
    this.dni,
    this.codigoEmpleado,
  });

  final String empleadoId;
  final List<double> embedding;
  final String displayName;
  final String? dni;
  final String? codigoEmpleado;
}

class BiometriaConfig {
  BiometriaConfig({
    required this.similarityThreshold,
    required this.duplicateWindowSeconds,
  });

  final double similarityThreshold;
  final int duplicateWindowSeconds;

  factory BiometriaConfig.fallback() => BiometriaConfig(
        similarityThreshold: kDefaultSimilarityThreshold,
        duplicateWindowSeconds: kFallbackCooldownSeconds,
      );
}
