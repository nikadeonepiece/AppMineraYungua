import '../../config/app_config.dart';
import '../../core/network/network_exception.dart';
import '../../core/network/sync_error_classifier.dart';
import '../../core/utils/replay_timestamp.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/marcaciones_upload_result.dart';
import '../../domain/repositories/marcaciones_repository.dart';
import '../../optimization/batching/sync_batch_policy.dart';
import '../../optimization/performance/performance_monitor.dart';
import '../../security/encryption/request_signature_service.dart';
import '../local/datasources/empleado_local_datasource.dart';
import '../local/datasources/marcacion_local_datasource.dart';
import '../local/models/marcacion_local.dart';
import '../local/models/sync_status.dart';
import '../remote/datasources/marcaciones_remote_datasource.dart';

class MarcacionesRepositoryImpl implements MarcacionesRepository {
  MarcacionesRepositoryImpl({
    required MarcacionLocalDatasource local,
    required MarcacionesRemoteDatasource remote,
    EmpleadoLocalDatasource? empleadoLocal,
    RequestSignatureService? signatureService,
  })  : _local = local,
        _remote = remote,
        _empleadoLocal = empleadoLocal ?? EmpleadoLocalDatasource(),
        _signatureService = signatureService ?? RequestSignatureService(kReplaySecret);

  final MarcacionLocalDatasource _local;
  final MarcacionesRemoteDatasource _remote;
  final EmpleadoLocalDatasource _empleadoLocal;
  final RequestSignatureService _signatureService;
  final SyncBatchPolicy _batchPolicy = const SyncBatchPolicy();

  @override
  Future<void> enqueueMarcacion(MarcacionLocal marcacion) => _local.upsert(marcacion);

  /// El sync Nest devuelve [id] como UUID (string); otros endpoints podrían usar entero.
  static int? _coerceServerId(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  /// Filas Isar anteriores al campo [MarcacionLocal.metodo] pueden quedar con cadena vacía; el API rechaza eso con 400.
  static String _normalizeMetodoForApi(String? raw) {
    final m = raw?.trim().toLowerCase() ?? '';
    if (m == 'facial' || m == 'qr' || m == 'dni') return m;
    return 'facial';
  }

  /// Repara UUID/hash de filas antiguas (empleado_id numérico o hash con claves ordenadas).
  Future<void> _ensurePayloadForUpload(MarcacionLocal item) async {
    if (item.empleadoUuid.trim().isEmpty) {
      final emp = await _empleadoLocal.getByRemoteId(item.empleadoId);
      final u = emp?.remoteUuid.trim() ?? '';
      if (u.isEmpty) {
        throw StateError(
          'Empleado local ${item.empleadoId} sin UUID. Sincronice empleados y reintente.',
        );
      }
      item.empleadoUuid = u;
    }
    item.metodo = _normalizeMetodoForApi(item.metodo);
    final fechaIso = marcacionFechaUtcIsoForReplay(item.fechaHora);
    item.payloadHash = _signatureService.computeMarcacionOfflinePayloadHash(
      uuid: item.uuid,
      empleadoId: item.empleadoUuid,
      fechaHoraUtcIso: fechaIso,
      tipo: item.tipo,
      metodo: item.metodo,
      latitud: item.latitud,
      longitud: item.longitud,
      fotoPath: item.fotoPath,
      deviceId: item.deviceId,
    );
    // request_ts debe estar cerca del reloj del servidor al enviar; las colas antiguas fallaban con "Timestamp fuera de ventana".
    item.requestTimestampMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    item.requestSignature = _signatureService.computeNonceSignature(
      item.nonce,
      item.payloadHash,
      item.requestTimestampMs,
    );
    await _local.upsert(item);
  }

  @override
  Future<MarcacionesUploadResult> uploadPending({
    required int maxRetryCount,
    bool ignoreRetryLimit = false,
  }) async {
    PerformanceMonitor.instance.start('sync_marcaciones_total');
    final pending = await _local.getPending(includeInBackoff: ignoreRetryLimit);
    var syncedCount = 0;
    var uploadAttempts = 0;
    var transientDeferred = 0;
    var permanentFailures = 0;
    String? lastErrorMessage;
    final valid = ignoreRetryLimit
        ? pending.toList(growable: false)
        : pending.where((e) => e.retryCount < maxRetryCount).toList(growable: false);
    if (valid.isEmpty && pending.isNotEmpty && !ignoreRetryLimit) {
      AppLogger.instance.w(
        'Marcaciones: ${pending.length} en cola pero ninguna elegible (reintentos >= $maxRetryCount). '
        'Pulse sincronizar en Ultimas marcaciones para reintentar todas.',
      );
    }
    for (var i = 0; i < valid.length; i += _batchPolicy.batchSize) {
      final end = (i + _batchPolicy.batchSize < valid.length)
          ? i + _batchPolicy.batchSize
          : valid.length;
      final batch = valid.sublist(i, end);
      AppLogger.instance.i('Sync batch marcaciones ${i ~/ _batchPolicy.batchSize + 1}: ${batch.length}');
      for (final item in batch) {
        await _local.updateSyncStatus(item.uuid, SyncStatus.syncing);
        try {
          await _ensurePayloadForUpload(item);
        } catch (e, st) {
          lastErrorMessage = e.toString();
          AppLogger.instance.e(
            'Marcacion ${item.uuid} no lista para subir',
            error: e,
            stackTrace: st,
          );
          permanentFailures++;
          await _local.updateSyncStatus(
            item.uuid,
            SyncStatus.failed,
            retryCount: item.retryCount + 1,
            lastUploadError: SyncErrorClassifier.truncateMessage(e.toString()),
          );
          continue;
        }
        final fechaIso = marcacionFechaUtcIsoForReplay(item.fechaHora);
        uploadAttempts++;
        try {
          final payload = <String, dynamic>{
            'uuid': item.uuid,
            'empleado_id': item.empleadoUuid,
            'fecha_hora': fechaIso,
            'tipo': item.tipo,
            'metodo': item.metodo,
            'device_id': item.deviceId,
            'nonce': item.nonce,
            'request_ts': item.requestTimestampMs,
            'payload_hash': item.payloadHash,
            'request_signature': item.requestSignature,
          };
          if (item.latitud != null) payload['latitud'] = item.latitud;
          if (item.longitud != null) payload['longitud'] = item.longitud;
          if (item.fotoPath != null && item.fotoPath!.trim().isNotEmpty) {
            payload['foto_path'] = item.fotoPath;
          }
          final response = await _remote.uploadMarcacion(payload);
          await _local.updateSyncStatus(
            item.uuid,
            SyncStatus.synced,
            serverId: _coerceServerId(response['id']),
          );
          syncedCount++;
        } on NetworkException catch (e, st) {
          lastErrorMessage = e.message;
          final kind = SyncErrorClassifier.classifyNetwork(e);
          AppLogger.instance.e(
            'Fallo subiendo marcacion ${item.uuid}: ${e.message} (${kind.name})',
            error: e,
            stackTrace: st,
          );
          if (kind == OfflineSyncErrorKind.transient) {
            transientDeferred++;
            await _local.updateSyncStatus(
              item.uuid,
              SyncStatus.pending,
              retryCount: item.retryCount,
              backoffUntil: SyncErrorClassifier.transientBackoffUntil(item.retryCount),
              lastUploadError: SyncErrorClassifier.truncateMessage(e.message),
            );
          } else {
            permanentFailures++;
            await _local.updateSyncStatus(
              item.uuid,
              SyncStatus.failed,
              retryCount: item.retryCount + 1,
              lastUploadError: SyncErrorClassifier.truncateMessage(e.message),
            );
          }
        } catch (e, st) {
          lastErrorMessage = e.toString();
          AppLogger.instance.e('Error inesperado subiendo marcacion ${item.uuid}', error: e, stackTrace: st);
          transientDeferred++;
          await _local.updateSyncStatus(
            item.uuid,
            SyncStatus.pending,
            retryCount: item.retryCount,
            backoffUntil: SyncErrorClassifier.transientBackoffUntil(item.retryCount),
            lastUploadError: SyncErrorClassifier.truncateMessage(e.toString()),
          );
        }
      }
    }
    PerformanceMonitor.instance.stop(
      'sync_marcaciones_total',
      extra: {
        'pending': pending.length,
        'eligible': valid.length,
        'synced': syncedCount,
        'ignore_retry_limit': ignoreRetryLimit,
        'transient_deferred': transientDeferred,
        'permanent_failures': permanentFailures,
      },
    );
    return MarcacionesUploadResult(
      synced: syncedCount,
      attempted: uploadAttempts,
      lastErrorMessage: lastErrorMessage,
      transientDeferred: transientDeferred,
      permanentFailures: permanentFailures,
    );
  }
}
