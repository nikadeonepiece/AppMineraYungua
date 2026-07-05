import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/network/network_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/session_store.dart';
import '../../../security/ssl_pinning/ssl_pinning_service.dart';
import '../../../security/time/time_integrity_service.dart';
import 'paged_list_response.dart';

class DioClient {
  DioClient({Dio? dio, SessionStore? sessionStore})
      : _dio = dio ?? Dio(),
        _sessionStore = sessionStore ?? SessionStore() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = ApiConfig.connectTimeout
      ..receiveTimeout = ApiConfig.receiveTimeout
      ..sendTimeout = ApiConfig.sendTimeout;
    SslPinningService(allowedSha256Fingerprints: ApiConfig.sslPins)
        .attach(_dio);
    final timeIntegrity = TimeIntegrityService();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.headers.containsKey('Authorization')) {
            // Sync/operaciones offline usan este cliente y requieren token activo.
            // Si no existe sesión, dejamos que el backend responda 401.
            final token = await _sessionStore.readAccess();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              AppLogger.instance.w(
                  'HTTP ${options.method} ${options.uri} sin token de sesion');
            }
          }
          AppLogger.instance.d('HTTP ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final data = response.data;
          if (data is Map<String, dynamic> && data['server_time'] is String) {
            final serverTime = DateTime.tryParse(data['server_time'] as String);
            if (serverTime != null &&
                !timeIntegrity.isSkewAcceptable(serverTime.toUtc())) {
              AppLogger.instance.w('Desfase de hora detectado contra servidor');
            }
          }
          AppLogger.instance
              .d('HTTP ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          final mapped = DioErrorMapper.map(error);
          AppLogger.instance.e(
            'HTTP ERROR ${error.requestOptions.uri}',
            error: mapped,
            stackTrace: error.stackTrace,
          );
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: mapped,
              type: error.type,
              stackTrace: error.stackTrace,
              message: mapped.message,
            ),
          );
        },
      ),
    );
  }

  final Dio _dio;
  final SessionStore _sessionStore;

  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await _dio.get<dynamic>(path, queryParameters: queryParameters);
      final body = _unwrap(response.data);
      if (body is! List) return [];
      return body.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      if (e.error is NetworkException) throw e.error! as NetworkException;
      throw DioErrorMapper.map(e);
    }
  }

  Future<PagedListResponse<Map<String, dynamic>>> getPagedList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await _dio.get<dynamic>(path, queryParameters: queryParameters);
      final payload = response.data;
      final body = _unwrap(payload);
      final data = body is List
          ? body.whereType<Map<String, dynamic>>().toList()
          : const <Map<String, dynamic>>[];
      final meta =
          payload is Map<String, dynamic> ? payload : const <String, dynamic>{};
      final page = (meta['page'] as num?)?.toInt() ?? 1;
      final limit = (meta['limit'] as num?)?.toInt() ?? data.length;
      final total = (meta['total'] as num?)?.toInt() ?? data.length;
      final count = (meta['count'] as num?)?.toInt() ?? data.length;
      final serverTime =
          DateTime.tryParse(meta['server_time']?.toString() ?? '');
      return PagedListResponse<Map<String, dynamic>>(
        data: data,
        page: page,
        limit: limit <= 0 ? data.length : limit,
        total: total < 0 ? data.length : total,
        count: count < 0 ? data.length : count,
        serverTime: serverTime,
      );
    } on DioException catch (e) {
      if (e.error is NetworkException) throw e.error! as NetworkException;
      throw DioErrorMapper.map(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      final data = _unwrap(response.data);
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on DioException catch (e) {
      if (e.error is NetworkException) throw e.error! as NetworkException;
      throw DioErrorMapper.map(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: body);
      final data = _unwrap(response.data);
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    } on DioException catch (e) {
      if (e.error is NetworkException) throw e.error! as NetworkException;
      throw DioErrorMapper.map(e);
    }
  }

  dynamic _unwrap(dynamic payload) {
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }
}
