import '../../config/app_config.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => kApiBase;
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  /// Reintentos por marcacion antes de pausar sync automatico (sync manual ignora el limite).
  static const int maxRetryCount = 15;

  static List<String> get sslPins {
    const pins = String.fromEnvironment('SSL_PINS', defaultValue: '');
    if (pins.trim().isEmpty) return const [];
    return pins
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }
}
