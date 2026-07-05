import '../../data/local/models/marcacion_local.dart';
import '../../data/local/datasources/biometria_local_datasource.dart';
import '../../data/local/datasources/empleado_local_datasource.dart';
import '../../data/local/datasources/marcacion_local_datasource.dart';
import '../../data/local/datasources/sync_metadata_local_datasource.dart';
import '../../data/local/datasources/usuario_local_datasource.dart';
import '../../data/remote/api_client/dio_client.dart';
import '../../data/remote/datasources/biometria_remote_datasource.dart';
import '../../data/remote/datasources/empleados_remote_datasource.dart';
import '../../data/remote/datasources/marcaciones_remote_datasource.dart';
import '../../data/remote/datasources/usuarios_remote_datasource.dart';
import '../../data/repositories/biometria_repository_impl.dart';
import '../../data/repositories/empleados_repository_impl.dart';
import '../../data/remote/datasources/tenants_remote_datasource.dart';
import '../../data/repositories/marcaciones_repository_impl.dart';
import '../../data/repositories/usuarios_repository_impl.dart';
import '../../data/sync/sync_manager.dart';
import '../../domain/usecases/marcacion_service.dart';
import '../network/connectivity_service.dart';

class OfflineBootstrap {
  OfflineBootstrap._();

  static final DioClient _dio = DioClient();
  static final EmpleadosRemoteDatasource empleadosRemote = EmpleadosRemoteDatasource(_dio);
  static final TenantsRemoteDatasource tenantsRemote = TenantsRemoteDatasource(_dio);
  static final EmpleadoLocalDatasource _empleadoLocal = EmpleadoLocalDatasource();
  static final UsuarioLocalDatasource _usuarioLocal = UsuarioLocalDatasource();
  static final BiometriaLocalDatasource _biometriaLocal = BiometriaLocalDatasource();
  static final MarcacionLocalDatasource _marcacionLocal = MarcacionLocalDatasource();
  static final SyncMetadataLocalDatasource _syncMetadataLocal = SyncMetadataLocalDatasource();

  static final MarcacionesRepositoryImpl _marcacionesRepository = MarcacionesRepositoryImpl(
    local: _marcacionLocal,
    remote: MarcacionesRemoteDatasource(_dio),
    empleadoLocal: _empleadoLocal,
  );

  static final SyncManager syncManager = SyncManager(
    empleadosRepository: EmpleadosRepositoryImpl(
      local: _empleadoLocal,
      remote: empleadosRemote,
    ),
    usuariosRepository: UsuariosRepositoryImpl(
      local: _usuarioLocal,
      remote: UsuariosRemoteDatasource(_dio),
    ),
    biometriaRepository: BiometriaRepositoryImpl(
      local: _biometriaLocal,
      remote: BiometriaRemoteDatasource(_dio),
    ),
    marcacionesRepository: _marcacionesRepository,
    syncMetadataDatasource: _syncMetadataLocal,
    tenantsRemote: tenantsRemote,
  );

  static final ConnectivityService connectivityService = ConnectivityService(syncManager);

  static final MarcacionService marcacionService = MarcacionService(
    marcacionesRepository: _marcacionesRepository,
    syncManager: syncManager,
    empleadoLocalDatasource: _empleadoLocal,
    biometriaLocalDatasource: _biometriaLocal,
    connectivityService: connectivityService,
  );

  static Future<int> pendingMarcacionesCount() async {
    final list = await _marcacionLocal.getPending(includeInBackoff: true);
    return list.length;
  }

  static Future<List<MarcacionLocal>> pendingMarcacionesList() =>
      _marcacionLocal.getPending(includeInBackoff: true);

  static Future<void> runLocalSecurityMigrations() async {
    await _biometriaLocal.migrateLegacyEmbeddings();
  }
}
