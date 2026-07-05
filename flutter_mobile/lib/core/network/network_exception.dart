class NetworkException implements Exception {
  NetworkException(this.message, {this.statusCode, this.errorCode});

  final String message;
  final int? statusCode;

  /// Código estable del API (p. ej. `NO_MATCH` en 422 de biometría), si el cuerpo lo incluye.
  final String? errorCode;

  @override
  String toString() =>
      'NetworkException(statusCode: $statusCode, errorCode: $errorCode, message: $message)';
}
