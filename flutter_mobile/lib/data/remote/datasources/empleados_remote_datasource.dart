import '../../../core/network/network_exception.dart';
import '../api_client/dio_client.dart';
import '../models/biometria_match_from_image_result.dart';
import 'sync_page_result.dart';

class EmpleadosRemoteDatasource {
  EmpleadosRemoteDatasource(this._client);
  final DioClient _client;

  /// InsightFace en servidor. Los 422 (sin coincidencia / ambiguo) no se convierten en null;
  /// el llamador decide si aplica fallback local (solo transporte / 5xx / timeout).
  Future<BiometriaMatchFromImageResult> matchBiometriaFromImage(
      String imageBase64) async {
    try {
      final data = await _client.post(
        '/empleados/biometria/match-from-image',
        body: {'imageBase64': imageBase64},
      );
      if (data.isEmpty) {
        return BiometriaMatchFromImageResult.fromNetworkException(
          NetworkException(
            'Respuesta vacía del servidor en match-from-image',
            statusCode: 502,
          ),
        );
      }
      return BiometriaMatchFromImageResult.success(data);
    } on NetworkException catch (e) {
      return BiometriaMatchFromImageResult.fromNetworkException(e);
    }
  }

  Future<SyncPageResult> getUpdatedAfter(
    DateTime? updatedAfter, {
    required int page,
    List<int>? areaIds,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (areaIds != null && areaIds.isNotEmpty) {
      query['id_areas'] = areaIds.join(',');
    } else {
      final cursor =
          updatedAfter ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      query['updated_after'] = cursor.toIso8601String();
    }
    final response = await _client.getPagedList(
      '/v1/sync/empleados',
      queryParameters: query,
    );
    return SyncPageResult(
      data: response.data,
      page: response.page,
      limit: response.limit,
      total: response.total,
      count: response.count,
      serverTime: response.serverTime,
    );
  }
}
