import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LivenessGuard {
  LivenessGuard({this.minHeadYawChange = 8, this.minHeadPitchChange = 6});

  final double minHeadYawChange;
  final double minHeadPitchChange;
  double? _lastYaw;
  double? _lastPitch;
  var _blinkDetected = false;

  bool validate(Face face) {
    final leftOpen = face.leftEyeOpenProbability;
    final rightOpen = face.rightEyeOpenProbability;
    if (leftOpen != null && rightOpen != null && leftOpen < 0.35 && rightOpen < 0.35) {
      _blinkDetected = true;
    }

    final currentYaw = face.headEulerAngleY ?? 0;
    final currentPitch = face.headEulerAngleX ?? 0;
    final yawOk = _lastYaw == null || (currentYaw - _lastYaw!).abs() >= minHeadYawChange;
    final pitchOk = _lastPitch == null || (currentPitch - _lastPitch!).abs() >= minHeadPitchChange;

    _lastYaw = currentYaw;
    _lastPitch = currentPitch;

    return _blinkDetected || yawOk || pitchOk;
  }
}
