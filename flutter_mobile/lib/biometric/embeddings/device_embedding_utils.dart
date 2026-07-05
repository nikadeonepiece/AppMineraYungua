import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'face_embedding_service.dart';

/// Promedia y normaliza L2 embeddings MobileFaceNet de varias capturas de alta.
List<double> promediarEmbeddingsDispositivo(List<List<double>> vectores) {
  if (vectores.isEmpty) return const [];
  final dim = vectores.first.length;
  final suma = List<double>.filled(dim, 0);
  for (final v in vectores) {
    for (var i = 0; i < dim && i < v.length; i++) {
      suma[i] += v[i];
    }
  }
  final n = vectores.length.toDouble();
  return _l2Normalize(suma.map((e) => e / n).toList());
}

List<double> _l2Normalize(List<double> v) {
  var norm = 0.0;
  for (final x in v) {
    norm += x * x;
  }
  norm = math.sqrt(norm);
  if (norm <= 1e-12) return v;
  return v.map((x) => x / norm).toList();
}

Future<List<double>> embeddingsDesdeJpegsCaptura(
  List<Uint8List> jpegs,
  FaceEmbeddingService embeddingService,
) async {
  final out = <List<double>>[];
  for (final bytes in jpegs) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) continue;
    out.add(embeddingService.generateEmbedding(decoded));
  }
  return promediarEmbeddingsDispositivo(out);
}
