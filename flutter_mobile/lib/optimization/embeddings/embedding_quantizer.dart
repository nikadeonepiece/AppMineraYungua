import 'dart:typed_data';

class EmbeddingQuantizer {
  const EmbeddingQuantizer();

  Int16List quantizeToInt16(List<double> values) {
    final out = Int16List(values.length);
    for (var i = 0; i < values.length; i++) {
      final clamped = values[i].clamp(-1.0, 1.0);
      out[i] = (clamped * 32767).round();
    }
    return out;
  }

  List<double> dequantizeFromInt16(Int16List values) {
    return List<double>.generate(
      values.length,
      (i) => values[i] / 32767.0,
      growable: false,
    );
  }
}
