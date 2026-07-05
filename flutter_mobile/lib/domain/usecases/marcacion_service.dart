import 'package:uuid/uuid.dart';

import '../../config/app_config.dart';
import '../../core/network/network_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/replay_timestamp.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/local/datasources/biometria_local_datasource.dart';
import '../../data/local/datasources/empleado_local_datasource.dart';
import '../../data/local/models/marcacion_local.dart';
import '../../data/local/models/sync_status.dart';
import '../../data/sync/sync_manager.dart';
import '../../security/encryption/request_signature_service.dart';
import '../../security/audit/security_audit_service.dart';
import '../marcaciones_upload_result.dart';
import '../repositories/marcaciones_repository.dart';

class MarcacionService {
  MarcacionService({
    required MarcacionesRepository marcacionesRepository,
    required SyncManager syncManager,
    EmpleadoLocalDatasource? empleadoLocalDatasource,
    BiometriaLocalDatasource? biometriaLocalDatasource,
    ConnectivityService? connectivityService,
  })  : _marcacionesRepository = marcacionesRepository,
        _syncManager = syncManager,
        _empleadoLocal = empleadoLocalDatasource ?? EmpleadoLocalDatasource(),
        _biometriaLocal = biometriaLocalDatasource ?? BiometriaLocalDatasource(),
        _connectivity = connectivityService;

  final MarcacionesRepository _marcacionesRepository;
  final SyncManager _syncManager;
  final EmpleadoLocalDatasource _empleadoLocal;
  final BiometriaLocalDatasource _biometriaLocal;
  final ConnectivityService? _connectivity;
  final Uuid _uuid = const Uuid();
  final RequestSignatureService _signatureService = RequestSignatureService(kReplaySecret);

  Future<MarcacionLocal> registrarMarcacion(
    int empleadoId,
    String tipo, {
    String metodo = 'facial',
    double? latitud,
    double? longitud,
    String? fotoPath,
  }) async {
    final empRow = await _empleadoLocal.getByRemoteId(empleadoId);
    final empleadoUuid = empRow?.remoteUuid.trim() ?? '';
    if (empleadoUuid.isEmpty) {
      throw StateError(
        'Empleado sin UUID local. Ejecute sincronizacion de empleados antes de marcar.',
      );
    }

    final connectivity = _connectivity;
    if (metodo == 'facial' &&
        connectivity != null &&
        !await connectivity.isCurrentlyOnline()) {
      final hasDevice =
          await _biometriaLocal.hasStoredDeviceEmbeddingForEmpleado(empleadoId);
      if (!hasDevice) {
        throw StateError(
          'Sin plantilla offline (dispositivo) para este trabajador. Sincronice biometría '
          'con red o re-registre desde la app móvil.',
        );
      }
    }

    final now = DateTime.now();
    final nonce = _uuid.v4();
    final ts = now.toUtc().millisecondsSinceEpoch;
    final generatedUuid = _uuid.v4();
    final fechaIso = marcacionFechaUtcIsoForReplay(now);
    final payloadHash = _signatureService.computeMarcacionOfflinePayloadHash(
      uuid: generatedUuid,
      empleadoId: empleadoUuid,
      fechaHoraUtcIso: fechaIso,
      tipo: tipo,
      metodo: metodo,
      latitud: latitud,
      longitud: longitud,
      fotoPath: fotoPath,
      deviceId: kDeviceId,
    );
    final signature = _signatureService.computeNonceSignature(nonce, payloadHash, ts);
    final record = MarcacionLocal()
      ..uuid = generatedUuid
      ..empleadoId = empleadoId
      ..empleadoUuid = empleadoUuid
      ..fechaHora = now
      ..tipo = tipo
      ..metodo = metodo
      ..latitud = latitud
      ..longitud = longitud
      ..fotoPath = fotoPath
      ..deviceId = kDeviceId
      ..nonce = nonce
      ..requestTimestampMs = ts
      ..payloadHash = payloadHash
      ..requestSignature = signature
      ..syncStatus = SyncStatus.pending
      ..retryCount = 0
      ..createdAt = now;

    await _marcacionesRepository.enqueueMarcacion(record);
    AppLogger.instance.i('Marcacion local registrada: ${record.uuid}');
    SecurityAuditService.instance.info(
      'marcacion_local_queued',
      meta: {
        'uuid': record.uuid,
        'empleado_id': record.empleadoId,
        'device_id': record.deviceId,
      },
    );

    try {
      await syncMarcacionesPendientes();
    } on NetworkException {
      // Si no hay red, la cola queda pendiente para reintento automático.
    }
    return record;
  }

  Future<MarcacionesUploadResult> syncMarcacionesPendientes({bool ignoreRetryLimit = false}) async {
    return _syncManager.uploadMarcaciones(ignoreRetryLimit: ignoreRetryLimit);
  }
}
