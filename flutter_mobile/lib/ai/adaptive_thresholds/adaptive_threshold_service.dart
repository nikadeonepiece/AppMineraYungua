class AdaptiveThresholdContext {
  AdaptiveThresholdContext({
    required this.baseThreshold,
    required this.faceQuality,
    required this.devicePerformanceScore,
    required this.historicalAccuracy,
    required this.lowLight,
  });

  final double baseThreshold;
  final double faceQuality; // 0..1
  final double devicePerformanceScore; // 0..1
  final double historicalAccuracy; // 0..1
  final bool lowLight;
}

class AdaptiveThresholdService {
  double resolve(AdaptiveThresholdContext ctx) {
    var threshold = ctx.baseThreshold;

    // Si la calidad facial es baja, subimos el umbral para bajar falsos positivos.
    if (ctx.faceQuality < 0.45) threshold += 0.08;
    if (ctx.faceQuality > 0.75) threshold -= 0.03;

    // En dispositivos lentos ajustamos ligeramente a favor de estabilidad.
    if (ctx.devicePerformanceScore < 0.45) threshold += 0.02;

    // Si el histórico es bueno, permitimos umbral un poco más flexible.
    if (ctx.historicalAccuracy > 0.92) threshold -= 0.02;
    if (ctx.historicalAccuracy < 0.75) threshold += 0.03;

    if (ctx.lowLight) threshold += 0.03;

    return threshold.clamp(0.55, 0.90);
  }
}

