import '../../core/utils/app_logger.dart';
import '../../domain/repositories/biometria_repository.dart';
import '../../domain/sync/sync_pull_result.dart';
import '../local/datasources/biometria_local_datasource.dart';
import '../local/models/empleado_biometria_local.dart';
import '../remote/datasources/biometria_remote_datasource.dart';

class BiometriaRepositoryImpl implements BiometriaRepository {
  BiometriaRepositoryImpl({
    required BiometriaLocalDatasource local,
    required BiometriaRemoteDatasource remote,
  })  : _local = local,
        _remote = remote;

  final BiometriaLocalDatasource _local;
  final BiometriaRemoteDatasource _remote;

  @override
  Future<SyncPullResult> syncIncremental(
    DateTime? updatedAfter, {
    List<int>? areaIds,
  }) async {
    var page = 1;
    var totalFetched = 0;
    DateTime? nextCursor = updatedAfter;

    while (true) {
      final response = await _remote.getUpdatedAfter(
        areaIds != null && areaIds.isNotEmpty ? null : updatedAfter,
        page: page,
        areaIds: areaIds,
      );
      final list = response.data.map(_toLocal).toList();
      if (list.isNotEmpty) {
        await _local.upsertAll(list);
        totalFetched += list.length;
        nextCursor =
            _maxUpdatedAt(list, fallback: response.serverTime ?? nextCursor);
      } else {
        nextCursor ??= response.serverTime;
      }

      if (!response.hasMore || response.data.isEmpty) {
        AppLogger.instance.i(
          'Biometria sincronizada: $totalFetched (pagina final ${response.page}/${_pageCount(response.total, response.limit)})',
        );
        return SyncPullResult(
          count: totalFetched,
          nextCursor: nextCursor,
        );
      }
      page += 1;
    }
  }

  EmpleadoBiometriaLocal _toLocal(Map<String, dynamic> map) {
    final rawEmbedding = map['embedding'];
    final embedding = (rawEmbedding is List ? rawEmbedding : const <dynamic>[])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();
    final rawDevice = map['embedding_device'] ?? map['embeddingDevice'];
    final embeddingDevice =
        (rawDevice is List ? rawDevice : const <dynamic>[])
            .whereType<num>()
            .map((e) => e.toDouble())
            .toList();

    final remoteId = _stableId(map['id']);
    final empleadoId =
        _stableId(map['empleado_id'] ?? map['empleadoId'] ?? map['empleado']);

    return EmpleadoBiometriaLocal()
      ..remoteId = remoteId
      ..empleadoId = empleadoId
      ..embedding = embedding
      ..embeddingLegacy = embedding
      ..embeddingDevice = embeddingDevice
      ..embeddingDeviceLegacy = embeddingDevice
      ..activo = _toBool(map['activo'])
      ..updatedAt = DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now()
      ..syncedAt = DateTime.now();
  }

  int _stableId(dynamic raw) {
    if (raw is num) return raw.toInt();
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return 0;
    final asNum = int.tryParse(text);
    if (asNum != null) return asNum;
    return _fnv1a32(text);
  }

  bool _toBool(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final t = raw?.toString().trim().toLowerCase();
    return t == '1' ||
        t == 'true' ||
        t == 't' ||
        t == 'si' ||
        t == 'sí' ||
        t == 'yes' ||
        t == 'y' ||
        t == 'activo';
  }

  int _fnv1a32(String input) {
    var hash = 0x811C9DC5;
    for (final c in input.codeUnits) {
      hash ^= c;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }

  DateTime? _maxUpdatedAt(List<EmpleadoBiometriaLocal> list,
      {DateTime? fallback}) {
    DateTime? maxValue = fallback;
    for (final item in list) {
      final value = item.updatedAt;
      if (maxValue == null || value.isAfter(maxValue)) {
        maxValue = value;
      }
    }
    return maxValue;
  }

  int _pageCount(int total, int limit) {
    if (total <= 0 || limit <= 0) return 1;
    return ((total - 1) ~/ limit) + 1;
  }
}
