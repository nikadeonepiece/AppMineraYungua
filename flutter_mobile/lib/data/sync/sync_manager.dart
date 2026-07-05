import 'dart:async';

import '../../config/app_config.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/app_logger.dart';
import '../../optimization/cache/embedding_cache_service.dart';
import '../../optimization/performance/performance_monitor.dart';
import '../../security/audit/security_audit_service.dart';
import '../../domain/repositories/biometria_repository.dart';
import '../../domain/repositories/empleados_repository.dart';
import '../../domain/repositories/marcaciones_repository.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../../domain/marcaciones_upload_result.dart';
import '../../domain/sync/sync_pull_result.dart';
import '../local/datasources/sync_metadata_local_datasource.dart';
import '../remote/datasources/tenants_remote_datasource.dart';

class SyncManager {
  SyncManager({
    required EmpleadosRepository empleadosRepository,
    required UsuariosRepository usuariosRepository,
    required BiometriaRepository biometriaRepository,
    required MarcacionesRepository marcacionesRepository,
    required SyncMetadataLocalDatasource syncMetadataDatasource,
    TenantsRemoteDatasource? tenantsRemote,
  })  : _empleadosRepository = empleadosRepository,
        _usuariosRepository = usuariosRepository,
        _biometriaRepository = biometriaRepository,
        _marcacionesRepository = marcacionesRepository,
        _syncMetadataDatasource = syncMetadataDatasource,
        _tenantsRemote = tenantsRemote;

  final EmpleadosRepository _empleadosRepository;
  final UsuariosRepository _usuariosRepository;
  final BiometriaRepository _biometriaRepository;
  final MarcacionesRepository _marcacionesRepository;
  final SyncMetadataLocalDatasource _syncMetadataDatasource;
  final TenantsRemoteDatasource? _tenantsRemote;
  Future<void>? _syncAllInFlight;

  Future<void> _ensureTenantDevice() async {
    final t = _tenantsRemote;
    if (t == null) return;
    try {
      await t.ensureDeviceReady(kDeviceId);
    } catch (e, st) {
      AppLogger.instance.w(
        'No se pudo registrar el dispositivo en la empresa; la subida de marcaciones puede rechazarse: $e',
        stackTrace: st,
      );
    }
  }

  Future<void> syncAll() async {
    final currentRun = _syncAllInFlight;
    if (currentRun != null) {
      AppLogger.instance.i('syncAll reutiliza ejecución en curso');
      return currentRun;
    }

    final future = _runSyncAll();
    _syncAllInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_syncAllInFlight, future)) {
        _syncAllInFlight = null;
      }
    }
  }

  Future<void> _runSyncAll() async {
    final watch = Stopwatch()..start();
    AppLogger.instance.i('syncAll iniciado');
    SecurityAuditService.instance.info('sync_all_started');
    await _ensureTenantDevice();
    await syncEmpleados();
    await syncUsuarios();
    await syncBiometria();
    await uploadMarcaciones();
    watch.stop();
    AppLogger.instance
        .i('syncAll finalizado en ${watch.elapsedMilliseconds} ms');
    SecurityAuditService.instance.info(
      'sync_all_finished',
      meta: {'duration_ms': watch.elapsedMilliseconds},
    );
  }

  Future<void> syncEmpleados() async {
    await _syncEntity(
      entity: 'empleados',
      action: (lastSync) => _empleadosRepository.syncIncremental(lastSync),
    );
  }

  Future<void> syncUsuarios() async {
    await _syncEntity(
      entity: 'usuarios',
      action: (lastSync) => _usuariosRepository.syncIncremental(lastSync),
    );
  }

  Future<void> syncBiometria() async {
    await _syncEntity(
      entity: 'biometria',
      action: (lastSync) => _biometriaRepository.syncIncremental(lastSync),
    );
    EmbeddingCacheService.shared.invalidate();
  }

  Future<MarcacionesUploadResult> uploadMarcaciones(
      {bool ignoreRetryLimit = false}) async {
    await _ensureTenantDevice();
    PerformanceMonitor.instance.start('sync_upload_marcaciones');
    final result = await _marcacionesRepository.uploadPending(
      maxRetryCount: ApiConfig.maxRetryCount,
      ignoreRetryLimit: ignoreRetryLimit,
    );
    final elapsed = PerformanceMonitor.instance.stop(
      'sync_upload_marcaciones',
      extra: {'total': result.synced},
    );
    AppLogger.instance
        .i('Marcaciones subidas: ${result.synced} en $elapsed ms');
    return result;
  }

  Future<void> _syncEntity({
    required String entity,
    required Future<SyncPullResult> Function(DateTime? lastSync) action,
  }) async {
    final watch = Stopwatch()..start();
    final metadata = await _syncMetadataDatasource.getOrCreate(entity);
    final result = await action(metadata.lastSync);
    final nextCursor = result.nextCursor?.toUtc();
    if (nextCursor != null) {
      await _syncMetadataDatasource.setLastSync(entity, nextCursor);
    }
    watch.stop();
    AppLogger.instance.i(
      'Sync de $entity completo: ${result.count} registros en ${watch.elapsedMilliseconds} ms'
      '${nextCursor != null ? ' · cursor ${nextCursor.toIso8601String()}' : ''}',
    );
  }
}
