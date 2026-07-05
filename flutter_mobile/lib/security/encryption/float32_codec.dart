import 'dart:typed_data';

class Float32Codec {
  const Float32Codec();

  Uint8List encode(List<double> values) {
    final out = Float32List(values.length);
    for (var i = 0; i < values.length; i++) {
      out[i] = values[i];
    }
    return out.buffer.asUint8List();
  }

  List<double> decode(Uint8List bytes) {
    if (bytes.isEmpty) return const [];
    final aligned = bytes.lengthInBytes ~/ Float32List.bytesPerElement;
    final view = Float32List.view(bytes.buffer, bytes.offsetInBytes, aligned);
    return List<double>.unmodifiable(view);
  }
}
