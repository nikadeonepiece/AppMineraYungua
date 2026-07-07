import 'dart:convert';

import '../config/app_config.dart';
import '../models/catalog_entry.dart';
import 'api_client.dart';

class BiometricApi {
  BiometricApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> searchEmployees(String accessToken, String query) async {
    final data = await _client.getJson(
      '/empleados/biometria/buscar',
      bearer: accessToken,
      query: {'q': query},
    );
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> fetchBiometriaStatus(
    String accessToken,
    String empleadoId,
  ) async {
    final data = await _client.getJson(
      '/empleados/biometria/estado',
      bearer: accessToken,
      query: {'empleado_id': empleadoId},
    );
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<BiometriaConfig> fetchConfig(String accessToken) async {
    final data = await _client.getJson(
      '/empleados/biometria/config',
      bearer: accessToken,
      query: {'dispositivo_id': kDeviceId},
    );
    if (data is! Map<String, dynamic>) return BiometriaConfig.fallback();
    final st = data['similarityThreshold'];
    final dw = data['duplicateWindowSeconds'];
    return BiometriaConfig(
      similarityThreshold: st is num ? st.toDouble() : kDefaultSimilarityThreshold,
      duplicateWindowSeconds: dw is num ? dw.toInt() : kFallbackCooldownSeconds,
    );
  }

  Future<List<CatalogEntry>> fetchCatalog(String accessToken) async {
    final data = await _client.getJson('/empleados/biometria/catalogo', bearer: accessToken);
    if (data is! List) return [];
    final out = <CatalogEntry>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['empleadoId'] as String?;
      final emb = item['embedding'];
      if (id == null || emb is! List) continue;
      final floats = emb.map((e) => (e as num).toDouble()).toList();
      if (floats.isEmpty) continue;
      final n = item['nombres'] as String? ?? '';
      final a = item['apellidos'] as String? ?? '';
      final dni = item['dni'] as String?;
      final cod = item['codigoEmpleado'] as String?;
      final name = ('$n $a').trim();
      out.add(CatalogEntry(
        empleadoId: id,
        embedding: floats,
        displayName: name.isEmpty ? (dni ?? id) : name,
        dni: dni,
        codigoEmpleado: cod,
      ));
    }
    return out;
  }

  /// Compara dos capturas del alta (InsightFace). Tras la 2.ª foto en registro.
  Future<Map<String, dynamic>> validarParCapturas(
    String accessToken, {
    required List<int> jpegA,
    required List<int> jpegB,
  }) async {
    final data = await _client.postJson(
      '/empleados/biometria/validar-par-capturas',
      bearer: accessToken,
      body: {
        'imageBase641': base64Encode(jpegA),
        'imageBase642': base64Encode(jpegB),
      },
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<double>> generateEmbedding(String accessToken, List<int> jpegBytes) async {
    final b64 = base64Encode(jpegBytes);
    final data = await _client.postJson(
      '/empleados/biometria/generate-embedding',
      bearer: accessToken,
      body: {'imageBase64': b64},
    );
    final emb = data['embedding'];
    if (emb is! List) throw StateError('Sin embedding');
    return emb.map((e) => (e as num).toDouble()).toList();
  }

  Future<Map<String, dynamic>> registerBiometria(
    String accessToken, {
    required String empleadoId,
    required List<List<int>> jpegImages,
    List<double>? embeddingDevice,
  }) async {
    final imagesBase64 = jpegImages.map(base64Encode).toList();
    final body = <String, dynamic>{
      'empleadoId': empleadoId,
      'imagenesBase64': imagesBase64,
    };
    if (embeddingDevice != null && embeddingDevice.length >= 16) {
      body['embeddingDevice'] = embeddingDevice;
    }
    return _client.postJson(
      '/empleados/biometria/registro',
      bearer: accessToken,
      body: body,
    );
  }

  Future<String> marcarFacial(String accessToken, String empleadoId) async {
    final data = await _client.postJson(
      '/asistencia/marcar',
      bearer: accessToken,
      body: {
        'empleado_id': empleadoId,
        'metodo': 'facial',
        'dispositivo_id': kDeviceId,
      },
    );
    return data['mensaje'] as String? ?? 'Marcacion registrada correctamente';
  }

  Future<String> marcarManual(String accessToken, String empleadoId) async {
    final data = await _client.postJson(
      '/asistencia/marcar',
      bearer: accessToken,
      body: {
        'empleado_id': empleadoId,
        'metodo': 'dni',
        'dispositivo_id': kDeviceId,
      },
    );
    return data['mensaje'] as String? ?? 'Marcacion registrada correctamente';
  }

  Future<String> marcarQr(String accessToken, String empleadoId) async {
    final data = await _client.postJson(
      '/asistencia/marcar',
      bearer: accessToken,
      body: {
        'empleado_id': empleadoId,
        'metodo': 'qr',
        'dispositivo_id': kDeviceId,
      },
    );
    return data['mensaje'] as String? ?? 'Marcacion registrada correctamente';
  }

  Future<List<Map<String, dynamic>>> fetchLatestMarks(String accessToken) async {
    final data = await _client.getJson('/asistencia', bearer: accessToken);
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_normalizeMarkRow)
        .toList(growable: false);
  }

  /// El API móvil devuelve snake_case; la UI usa camelCase.
  static Map<String, dynamic> _normalizeMarkRow(Map<String, dynamic> row) {
    final empleadoId =
        (row['empleadoId'] ?? row['empleado_id'])?.toString().trim() ?? '';
    final tipo = (row['tipoEvento'] ?? row['tipo'])?.toString();
    final timestamp = (row['timestamp'] ?? row['fecha_hora'])?.toString();
    final metodo = row['metodo']?.toString();

    final nombres = row['nombres']?.toString().trim() ?? '';
    final apellidos = row['apellidos']?.toString().trim() ?? '';
    final dni = row['dni']?.toString().trim() ?? '';
    final nombre = '$nombres $apellidos'.trim();
    final empleadoDisplay = [
      if (nombre.isNotEmpty) nombre,
      if (dni.isNotEmpty) '($dni)',
    ].join(' ');

    return {
      ...row,
      if (empleadoId.isNotEmpty) 'empleadoId': empleadoId,
      if (tipo != null && tipo.isNotEmpty) 'tipoEvento': tipo,
      if (timestamp != null && timestamp.isNotEmpty) 'timestamp': timestamp,
      if (metodo != null && metodo.isNotEmpty) 'metodo': metodo,
      if (empleadoDisplay.isNotEmpty) 'empleadoDisplay': empleadoDisplay,
    };
  }
}
