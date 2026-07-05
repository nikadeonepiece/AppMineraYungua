import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/utils/replay_timestamp.dart';

class RequestSignatureService {
  RequestSignatureService(this._secret);
  final String _secret;

  String computePayloadHash(Map<String, dynamic> payload) {
    final canonical = jsonEncode(_sort(payload));
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  String computeNonceSignature(String nonce, String payloadHash, int timestampMs) {
    final raw = '$nonce|$payloadHash|$timestampMs|$_secret';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// Orden de claves idéntico a `JSON.stringify({...})` en `marcaciones-sync.service.ts`.
  String computeMarcacionOfflinePayloadHash({
    required String uuid,
    required String empleadoId,
    required String fechaHoraUtcIso,
    required String tipo,
    required String metodo,
    double? latitud,
    double? longitud,
    String? fotoPath,
    required String deviceId,
  }) {
    final fechaNormalizada =
        marcacionFechaUtcIsoForReplay(DateTime.parse(fechaHoraUtcIso));
    final map = <String, dynamic>{
      'uuid': uuid,
      'empleado_id': empleadoId,
      'fecha_hora': fechaNormalizada,
      'tipo': tipo,
      'metodo': metodo,
      'latitud': latitud,
      'longitud': longitud,
      'foto_path': fotoPath,
      'device_id': deviceId,
    };
    return sha256.convert(utf8.encode(jsonEncode(map))).toString();
  }

  Object? _sort(Object? value) {
    if (value is Map<String, dynamic>) {
      final keys = value.keys.toList()..sort();
      return {for (final k in keys) k: _sort(value[k])};
    }
    if (value is List) return value.map(_sort).toList();
    return value;
  }
}
