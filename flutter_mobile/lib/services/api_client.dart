import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Cliente HTTP con prefijo `/api` y envoltorio `{ data: T }`.
class ApiClient {
  ApiClient({String? baseUrl, Duration? timeout})
      : baseUrl = (baseUrl ?? kApiBase).replaceAll(RegExp(r'/+$'), ''),
        timeout = timeout ?? const Duration(seconds: 45);

  final String baseUrl;
  final Duration timeout;

  Uri _uri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p');
  }

  static dynamic unwrap(dynamic jsonBody) {
    if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('data')) {
      return jsonBody['data'];
    }
    return jsonBody;
  }

  static String parseErrorMessage(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map<String, dynamic>) {
        final msg = m['message'];
        if (msg is String) return msg;
        if (msg is Map && msg['message'] is String) return msg['message'] as String;
        if (msg is List && msg.isNotEmpty) return msg.join(' ');
      }
    } catch (_) {}
    return body;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? bearer,
  }) async {
    final res = await http
        .post(
          _uri(path),
          headers: {
            'Content-Type': 'application/json',
            if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
          },
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      final decoded = jsonDecode(res.body);
      final unwrapped = unwrap(decoded);
      if (unwrapped is Map<String, dynamic>) return unwrapped;
      return {'value': unwrapped};
    }
    throw ApiException(res.statusCode, parseErrorMessage(res.body));
  }

  Future<dynamic> getJson(
    String path, {
    String? bearer,
    Map<String, String>? query,
  }) async {
    var uri = _uri(path);
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final res = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
          },
        )
        .timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      final decoded = jsonDecode(res.body);
      return unwrap(decoded);
    }
    throw ApiException(res.statusCode, parseErrorMessage(res.body));
  }

  Future<void> deleteJson(String path, {String? bearer}) async {
    final res = await http
        .delete(
          _uri(path),
          headers: {
            if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
          },
        )
        .timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw ApiException(res.statusCode, parseErrorMessage(res.body));
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
