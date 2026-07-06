import '../../core/utils/app_logger.dart';
import '../../domain/repositories/empleados_repository.dart';
import '../../domain/sync/sync_pull_result.dart';
import '../local/datasources/empleado_local_datasource.dart';
import '../local/models/empleado_local.dart';
import '../remote/datasources/empleados_remote_datasource.dart';

class EmpleadosRepositoryImpl implements EmpleadosRepository {
  EmpleadosRepositoryImpl({
    required EmpleadoLocalDatasource local,
    required EmpleadosRemoteDatasource remote,
  })  : _local = local,
        _remote = remote;

  final EmpleadoLocalDatasource _local;
  final EmpleadosRemoteDatasource _remote;

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
          'Empleados sincronizados: $totalFetched (pagina final ${response.page}/${_pageCount(response.total, response.limit)})',
        );
        return SyncPullResult(
          count: totalFetched,
          nextCursor: nextCursor,
        );
      }
      page += 1;
    }
  }

  EmpleadoLocal _toLocal(Map<String, dynamic> map) {
    final rawId = map['id'];
    final remoteId = _stableId(rawId);
    return EmpleadoLocal()
      ..remoteId = remoteId
      ..remoteUuid = rawId?.toString().trim() ?? ''
      ..dni = map['dni']?.toString() ?? ''
      ..codigoEmpleado = map['codigo_empleado']?.toString() ??
          map['codigoEmpleado']?.toString() ??
          ''
      ..nombres = map['nombres']?.toString() ?? ''
      ..apellidos = map['apellidos']?.toString() ?? ''
      ..area = map['area']?.toString() ?? ''
      ..cargo = map['cargo']?.toString() ?? ''
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

  DateTime? _maxUpdatedAt(List<EmpleadoLocal> list, {DateTime? fallback}) {
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
