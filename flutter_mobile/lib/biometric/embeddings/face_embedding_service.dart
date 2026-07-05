import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  FaceEmbeddingService._(this._interpreter) : _embeddingSize = _resolveEmbeddingSize(_interpreter);

  static const _inputSize = 112;

  final Interpreter _interpreter;
  final int _embeddingSize;

  static Future<FaceEmbeddingService> create() async {
    final model = await rootBundle.load('assets/models/mobilefacenet.tflite');
    final modelBytes = _toExactBytes(model);
    if (_looksLikePlaceholder(modelBytes)) {
      throw StateError(
        'Modelo local no configurado: reemplaza assets/models/mobilefacenet.tflite por un modelo real (112x112x3 -> embedding float).',
      );
    }

    try {
      final interpreter = await Interpreter.fromAsset('assets/models/mobilefacenet.tflite');
      return FaceEmbeddingService._(interpreter);
    } catch (assetError) {
      // Fallback para algunos dispositivos/ROMs donde la carga por asset falla.
      try {
        final interpreter = Interpreter.fromBuffer(modelBytes);
        return FaceEmbeddingService._(interpreter);
      } catch (bufferError) {
        throw StateError(
          'No se pudo cargar el modelo local (asset: $assetError, buffer: $bufferError).',
        );
      }
    }
  }

  static Uint8List _toExactBytes(ByteData data) {
    final offset = data.offsetInBytes;
    return data.buffer.asUint8List(offset, data.lengthInBytes);
  }

  static bool _looksLikePlaceholder(Uint8List bytes) {
    if (bytes.length < 1024) return true;
    final ascii = String.fromCharCodes(bytes.take(24));
    return ascii.startsWith('PLACEHOLDER_MODEL');
  }

  List<double> generateEmbedding(img.Image crop) {
    final resized = img.copyResize(crop, width: _inputSize, height: _inputSize);
    final input = _normalizeToInput(resized);
    final output = List.generate(1, (_) => List.filled(_embeddingSize, 0.0));
    _interpreter.run(input, output);
    final raw = output.first.cast<double>();
    return _l2Normalize(raw);
  }

  void dispose() {
    _interpreter.close();
  }

  List<List<List<List<double>>>> _normalizeToInput(img.Image image) {
    final tensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return <double>[(r - 0.5) / 0.5, (g - 0.5) / 0.5, (b - 0.5) / 0.5];
        }),
      ),
    );
    return tensor;
  }

  List<double> _l2Normalize(List<double> vector) {
    var sum = 0.0;
    for (final v in vector) {
      sum += v * v;
    }
    final norm = sum <= 0 ? 1.0 : math.sqrt(sum);
    return vector.map((v) => v / norm).toList(growable: false);
  }

  static int _resolveEmbeddingSize(Interpreter interpreter) {
    final shape = interpreter.getOutputTensor(0).shape;
    if (shape.isEmpty) return 192;
    final positiveDims = shape.where((d) => d > 0).toList(growable: false);
    if (positiveDims.isEmpty) return 192;
    // Normalmente [1, N] para embeddings.
    if (positiveDims.length >= 2) return positiveDims.last;
    return positiveDims.first;
  }
}
