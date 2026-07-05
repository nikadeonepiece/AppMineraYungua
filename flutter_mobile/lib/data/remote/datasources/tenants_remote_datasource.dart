import '../api_client/dio_client.dart';

class TenantsRemoteDatasource {
  TenantsRemoteDatasource(this._client);

  final DioClient _client;

  /// Registra el terminal en la empresa del JWT y lo activa; el backend exige esto para aceptar `/v1/marcaciones`.
  Future<void> ensureDeviceReady(String deviceId) async {
    await _client.post('/v1/tenants/devices/register', body: {'deviceId': deviceId});
    final encoded = Uri.encodeComponent(deviceId);
    await _client.patch('/v1/tenants/devices/$encoded/activate');
  }
}
