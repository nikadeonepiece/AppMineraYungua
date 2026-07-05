import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// La cámara frontal muestra espejo en preview pero el buffer del sensor no.
/// Volteamos el recorte/JPEG para alinear registro, marcación y lo que ve el usuario.
bool shouldMirrorFrontCamera(CameraLensDirection lens) =>
    lens == CameraLensDirection.front;

img.Image? mirrorRgbIfFront(img.Image? image, CameraLensDirection lens) {
  if (image == null || !shouldMirrorFrontCamera(lens)) return image;
  return img.flipHorizontal(image);
}

Uint8List mirrorJpegIfFront(Uint8List jpeg, CameraLensDirection lens) {
  if (!shouldMirrorFrontCamera(lens)) return jpeg;
  final decoded = img.decodeImage(jpeg);
  if (decoded == null) return jpeg;
  return Uint8List.fromList(img.encodeJpg(img.flipHorizontal(decoded), quality: 88));
}
