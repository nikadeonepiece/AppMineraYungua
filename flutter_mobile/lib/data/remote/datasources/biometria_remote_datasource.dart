import '../api_client/dio_client.dart';
import 'sync_page_result.dart';

class BiometriaRemoteDatasource {
  BiometriaRemoteDatasource(this._client);
  final DioClient _client;

  Future<SyncPageResult> getUpdatedAfter(
    DateTime? updatedAfter, {
    required int page,
  }) async {
    final cursor =
        updatedAfter ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final response = await _client.getPagedList(
      '/v1/sync/biometria',
      queryParameters: {
        'updated_after': cursor.toIso8601String(),
        'page': page,
      },
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
