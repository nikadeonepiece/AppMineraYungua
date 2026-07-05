import 'package:isar/isar.dart';

import 'sync_status.dart';

part 'marcacion_local.g.dart';

@collection
class MarcacionLocal {
  MarcacionLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late int empleadoId;

  /// UUID de empleado (anti-replay / API). Coincide con [EmpleadoLocal.remoteUuid].
  String empleadoUuid = '';

  late DateTime fechaHora;
  late String tipo;

  /// facial | qr | dni — mismo criterio que en servidor; no distingue offline.
  String metodo = 'facial';

  double? latitud;
  double? longitud;
  String? fotoPath;
  late String deviceId;
  late String nonce;
  late int requestTimestampMs;
  late String payloadHash;
  late String requestSignature;
  @enumerated
  SyncStatus syncStatus = SyncStatus.pending;
  int retryCount = 0;
  int? serverId;
  late DateTime createdAt;
  DateTime? syncedAt;

  /// Tras error de red o 5xx: no reintentar hasta esta hora (alivio de batería y servidor).
  DateTime? backoffUntil;

  /// Ultimo mensaje de error de subida (diagnostico en UI o logs).
  String lastUploadError = '';
}
