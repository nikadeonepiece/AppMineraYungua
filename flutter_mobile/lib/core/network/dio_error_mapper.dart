import 'dart:convert';

import 'package:dio/dio.dart';

import 'network_exception.dart';

class DioErrorMapper {
  DioErrorMapper._();

  static NetworkException map(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final raw = response?.data;
    final fallback = error.message ?? 'Error de red no controlado';
    final message = _extractServerMessage(raw, fallback);
    final errorCode = _extractServerErrorCode(raw);

    return NetworkException(
      message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }

  /// Códigos como `NO_MATCH` / `AMBIGUOUS` enviados por Nest dentro de `message` (objeto) o en raíz.
  static String? _extractServerErrorCode(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final top = map['code'];
    if (top is String) {
      final t = top.trim();
      if (t.isNotEmpty) return t;
    }
    final msg = map['message'];
    if (msg is Map) {
      final nested = Map<String, dynamic>.from(msg);
      final c = nested['code'];
      if (c is String) {
        final t = c.trim();
        if (t.isNotEmpty) return t;
      }
    }
    return null;
  }

  /// Nest + AllExceptionsFilter suele devolver `message` como string, lista u objeto anidado.
  static String _extractServerMessage(dynamic data, String fallback) {
    if (data == null) return fallback;

    if (data is String) {
      final t = data.trim();
      if (t.startsWith('{') || t.startsWith('[')) {
        try {
          final decoded = jsonDecode(t);
          return _extractServerMessage(decoded, fallback);
        } catch (_) {}
      }
      return t.isNotEmpty ? t : fallback;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['message'];

      if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
      if (msg is List && msg.isNotEmpty) {
        return msg.map((e) => e.toString()).join('; ');
      }
      if (msg is Map) {
        final nested = Map<String, dynamic>.from(msg);
        final inner = nested['message'];
        if (inner is List && inner.isNotEmpty) {
          return inner.map((e) => e.toString()).join('; ');
        }
        if (inner is String && inner.trim().isNotEmpty) {
          return inner.trim();
        }
      }

      final err = map['error'];
      if (err is String && err.trim().isNotEmpty) {
        return err.trim();
      }
    }

    return fallback;
  }
}
