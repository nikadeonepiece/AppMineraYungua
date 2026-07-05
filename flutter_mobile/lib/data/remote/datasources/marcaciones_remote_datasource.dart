import '../api_client/dio_client.dart';

class MarcacionesRemoteDatasource {
  MarcacionesRemoteDatasource(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> uploadMarcacion(Map<String, dynamic> payload) {
    return _client.post('/v1/marcaciones', body: payload);
  }
}
