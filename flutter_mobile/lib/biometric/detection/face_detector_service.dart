import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../utils/camera_image_utils.dart';

class FaceDetectorService {
  FaceDetectorService()
        : _detector = FaceDetector(
          options: FaceDetectorOptions(
            // Más preciso que `fast`: mejor caja alrededor de la cara (algo más costoso).
            performanceMode: FaceDetectorMode.accurate,
            enableTracking: true,
            enableClassification: true,
            enableLandmarks: false,
            enableContours: false,
            minFaceSize: 0.12,
          ),
        );

  final FaceDetector _detector;
  var _busy = false;

  Future<List<Face>> detect(CameraImage image, CameraController controller) async {
    if (_busy) return const [];
    _busy = true;
    try {
      final input = inputImageFromCameraImage(image, controller);
      if (input == null) return const [];
      return _detector.processImage(input);
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() => _detector.close();
}
