import '../api_client/dio_client.dart';

class SyncAreaItem {
  SyncAreaItem({
    required this.idArea,
    required this.nombre,
    required this.totalPersonal,
  });

  final int idArea;
  final String nombre;
  final int totalPersonal;

  factory SyncAreaItem.fromMap(Map<String, dynamic> map) {
    return SyncAreaItem(
      idArea: int.tryParse(map['id_area']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '—',
      totalPersonal: int.tryParse(map['total_personal']?.toString() ?? '') ?? 0,
    );
  }
}

class SyncAreasRemoteDatasource {
  SyncAreasRemoteDatasource(this._client);
  final DioClient _client;

  Future<List<SyncAreaItem>> fetchAreas() async {
    final response = await _client.getPagedList('/v1/sync/areas');
    return response.data
        .map(SyncAreaItem.fromMap)
        .where((a) => a.idArea > 0)
        .toList();
  }
}
