import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/widgets.dart' show Size;
import 'dart:io';
import 'dart:typed_data';

/// Convierte [CameraImage] YUV420 a RGB para recorte/JPEG.
img.Image? cameraImageToRgbImage(CameraImage image) {
  try {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final out = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      final uvRow = uvRowStride * (y >> 1);
      for (var x = 0; x < width; x++) {
        final uvOffset = uvRow + (x >> 1) * uvPixelStride;
        final yp = yBuffer[y * yPlane.bytesPerRow + x];
        final up = uBuffer[uvOffset];
        final vp = vBuffer[uvOffset];

        var r = (yp + (vp * 1436 ~/ 1024) - 179).round();
        var g = (yp - (up * 46549 ~/ 131072) + 44 - (vp * 93604 ~/ 131072) + 91).round();
        var b = (yp + (up * 1814 ~/ 1024) - 227).round();
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);
        out.setPixelRgb(x, y, r, g, b);
      }
    }
    return out;
  } catch (_) {
    return null;
  }
}

/// Convierte solo el rectángulo [left, top, width, height) de YUV420 a RGB.
/// Evita el coste de recorrer el fotograma completo en cada intento de reconocimiento.
/// Si el formato no es YUV de 3 planos, hace fallback a [cameraImageToRgbImage] + recorte.
img.Image? cameraImageRoiToRgbImage(
  CameraImage image, {
  required int left,
  required int top,
  required int width,
  required int height,
}) {
  final iw = image.width;
  final ih = image.height;
  var x0 = left.clamp(0, iw - 1);
  var y0 = top.clamp(0, ih - 1);
  var w = width.clamp(0, iw - x0);
  var h = height.clamp(0, ih - y0);
  if (w <= 0 || h <= 0) return null;

  if (image.planes.length < 3) {
    final full = cameraImageToRgbImage(image);
    if (full == null) return null;
    return img.copyCrop(full, x: x0, y: y0, width: w, height: h);
  }

  try {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    final yRowStride = yPlane.bytesPerRow;

    final out = img.Image(width: w, height: h);
    for (var yy = 0; yy < h; yy++) {
      final sy = y0 + yy;
      final uvRow = uvRowStride * (sy >> 1);
      for (var xx = 0; xx < w; xx++) {
        final sx = x0 + xx;
        final uvOffset = uvRow + (sx >> 1) * uvPixelStride;
        final yp = yBuffer[sy * yRowStride + sx];
        final up = uBuffer[uvOffset];
        final vp = vBuffer[uvOffset];

        var r = (yp + (vp * 1436 ~/ 1024) - 179).round();
        var g = (yp - (up * 46549 ~/ 131072) + 44 - (vp * 93604 ~/ 131072) + 91).round();
        var b = (yp + (up * 1814 ~/ 1024) - 227).round();
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);
        out.setPixelRgb(xx, yy, r, g, b);
      }
    }
    return out;
  } catch (_) {
    return null;
  }
}

/// [InputImage] para ML Kit a partir del stream de cámara (Android NV21 / iOS según formato).
InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraController controller,
) {
  final camera = controller.description;
  final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  if (rotation == null) return null;

  // ML Kit en Android funciona de forma más estable con NV21.
  if (Platform.isAndroid) {
    if (image.planes.length < 3) return null;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final width = image.width;
    final height = image.height;

    final nv21 = Uint8List(width * height * 3 ~/ 2);

    var dst = 0;
    for (var y = 0; y < height; y++) {
      final start = y * yPlane.bytesPerRow;
      nv21.setRange(dst, dst + width, yPlane.bytes, start);
      dst += width;
    }

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    for (var y = 0; y < height ~/ 2; y++) {
      for (var x = 0; x < width ~/ 2; x++) {
        final uvIndex = y * uvRowStride + x * uvPixelStride;
        // NV21 = VU
        nv21[dst++] = vPlane.bytes[uvIndex];
        nv21[dst++] = uPlane.bytes[uvIndex];
      }
    }

    return InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: width,
      ),
    );
  }

  // iOS: BGRA8888, normalmente 1 plano.
  if (image.planes.isEmpty) return null;
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;
  final plane = image.planes.first;
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    ),
  );
}
