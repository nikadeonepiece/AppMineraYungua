class AiModelMetadata {
  AiModelMetadata({
    required this.version,
    required this.assetPath,
    required this.createdAtIso,
    required this.notes,
    required this.rollbackVersion,
  });

  final String version;
  final String assetPath;
  final String createdAtIso;
  final String notes;
  final String? rollbackVersion;
}

class ModelRegistryService {
  AiModelMetadata currentModel() {
    return AiModelMetadata(
      version: 'mobilefacenet-v1',
      assetPath: 'assets/models/mobilefacenet.tflite',
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      notes: 'Modelo base actual en edge.',
      rollbackVersion: null,
    );
  }
}

