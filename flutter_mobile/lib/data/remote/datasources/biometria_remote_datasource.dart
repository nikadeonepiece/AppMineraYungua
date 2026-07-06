import '../api_client/dio_client.dart';
import 'sync_page_result.dart';

class BiometriaRemoteDatasource {
  BiometriaRemoteDatasource(this._client);
  final DioClient _client;

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
      '/v1/sync/biometria',
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
