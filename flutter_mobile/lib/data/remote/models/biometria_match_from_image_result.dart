import '../../../core/network/network_exception.dart';

/// Resultado de `POST /empleados/biometria/match-from-image`.
///
/// Distingue rechazo facial explícito (422) de errores de transporte o upstream
/// (sin respuesta HTTP, 5xx, timeout), donde tiene sentido intentar comparación local.
enum BiometriaMatchFromImageOutcome {
  success,
  noMatch,
  ambiguous,
  endpointRejected,
  transportOrUpstream,
}

class BiometriaMatchFromImageResult {
  const BiometriaMatchFromImageResult._({
    required this.outcome,
    this.payload,
    this.message,
    this.statusCode,
  });

  final BiometriaMatchFromImageOutcome outcome;
  final Map<String, dynamic>? payload;
  final String? message;
  final int? statusCode;

  bool get isSuccess => outcome == BiometriaMatchFromImageOutcome.success;

  /// Solo en estos casos se debe degradar a TFLite local sin ocultar un 422 del backend.
  bool get allowLocalFallback =>
      outcome == BiometriaMatchFromImageOutcome.transportOrUpstream;

  factory BiometriaMatchFromImageResult.success(Map<String, dynamic> payload) {
    return BiometriaMatchFromImageResult._(
      outcome: BiometriaMatchFromImageOutcome.success,
      payload: payload,
    );
  }

  /// Interpreta [NetworkException] tras fallo HTTP en el cliente Dio.
  factory BiometriaMatchFromImageResult.fromNetworkException(
    NetworkException e,
  ) {
    final code = e.statusCode;
    final lower = e.message.toLowerCase();

    if (code == 422) {
      final api = e.errorCode?.toUpperCase();
      BiometriaMatchFromImageOutcome facial;
      if (api == 'AMBIGUOUS') {
        facial = BiometriaMatchFromImageOutcome.ambiguous;
      } else if (api == 'NO_MATCH') {
        facial = BiometriaMatchFromImageOutcome.noMatch;
      } else {
        final ambiguous = lower.contains('ambig');
        facial = ambiguous
            ? BiometriaMatchFromImageOutcome.ambiguous
            : BiometriaMatchFromImageOutcome.noMatch;
      }
      return BiometriaMatchFromImageResult._(
        outcome: facial,
        message: e.message,
        statusCode: code,
      );
    }

    if (code == null || code >= 500 || code == 408) {
      return BiometriaMatchFromImageResult._(
        outcome: BiometriaMatchFromImageOutcome.transportOrUpstream,
        message: e.message,
        statusCode: code,
      );
    }

    return BiometriaMatchFromImageResult._(
      outcome: BiometriaMatchFromImageOutcome.endpointRejected,
      message: e.message,
      statusCode: code,
    );
  }
}
