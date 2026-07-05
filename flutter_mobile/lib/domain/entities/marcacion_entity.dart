import '../../data/local/models/sync_status.dart';

class MarcacionEntity {
  MarcacionEntity({
    required this.uuid,
    required this.empleadoId,
    required this.fechaHora,
    required this.tipo,
    this.latitud,
    this.longitud,
    this.fotoPath,
    required this.deviceId,
    required this.syncStatus,
    required this.retryCount,
  });

  final String uuid;
  final int empleadoId;
  final DateTime fechaHora;
  final String tipo;
  final double? latitud;
  final double? longitud;
  final String? fotoPath;
  final String deviceId;
  final SyncStatus syncStatus;
  final int retryCount;
}
