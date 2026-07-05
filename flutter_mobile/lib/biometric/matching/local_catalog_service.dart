import '../../data/local/datasources/biometria_local_datasource.dart';
import '../../data/local/datasources/empleado_local_datasource.dart';
import '../../optimization/cache/embedding_cache_service.dart';
import '../../optimization/performance/performance_monitor.dart';
import 'local_face_candidate.dart';

class LocalCatalogService {
  LocalCatalogService({
    BiometriaLocalDatasource? biometriaDatasource,
    EmpleadoLocalDatasource? empleadoDatasource,
    EmbeddingCacheService? cacheService,
  })  : _biometriaDatasource = biometriaDatasource ?? BiometriaLocalDatasource(),
        _empleadoDatasource = empleadoDatasource ?? EmpleadoLocalDatasource(),
        _cacheService = cacheService ?? EmbeddingCacheService.shared;

  final BiometriaLocalDatasource _biometriaDatasource;
  final EmpleadoLocalDatasource _empleadoDatasource;
  final EmbeddingCacheService _cacheService;

  Future<List<LocalFaceCandidate>> loadCandidates() async {
    final cached = _cacheService.get();
    if (cached != null) return cached;
    PerformanceMonitor.instance.start('catalog_load');
    final biometriaRows = await _biometriaDatasource.getAll();
    if (biometriaRows.isEmpty) return const [];
    final empleados = await _empleadoDatasource.getAll();
    final mapEmpleado = {for (final e in empleados) e.remoteId: e};

    final out = <LocalFaceCandidate>[];
    for (final bio in biometriaRows) {
      if (!bio.activo || bio.embedding.isEmpty) continue;
      final emp = mapEmpleado[bio.empleadoId];
      if (emp == null || !emp.activo) continue;
      out.add(
        LocalFaceCandidate(
          empleadoId: bio.empleadoId,
          displayName: emp.nombreCompleto.isEmpty ? emp.dni : emp.nombreCompleto,
          embedding: bio.embedding,
        ),
      );
    }
    _cacheService.set(out);
    PerformanceMonitor.instance.stop('catalog_load', extra: {'count': out.length});
    return out;
  }

  /// Catálogo para 1:N offline (MobileFaceNet, `embedding_device`).
  Future<List<LocalFaceCandidate>> loadDeviceCandidates() async {
    PerformanceMonitor.instance.start('catalog_device_load');
    final biometriaRows = await _biometriaDatasource.getAll();
    if (biometriaRows.isEmpty) return const [];
    final empleados = await _empleadoDatasource.getAll();
    final mapEmpleado = {for (final e in empleados) e.remoteId: e};

    final out = <LocalFaceCandidate>[];
    for (final bio in biometriaRows) {
      if (!bio.activo || bio.embeddingDevice.isEmpty) continue;
      final emp = mapEmpleado[bio.empleadoId];
      if (emp == null || !emp.activo) continue;
      out.add(
        LocalFaceCandidate(
          empleadoId: bio.empleadoId,
          displayName: emp.nombreCompleto.isEmpty ? emp.dni : emp.nombreCompleto,
          embedding: bio.embeddingDevice,
        ),
      );
    }
    PerformanceMonitor.instance.stop(
      'catalog_device_load',
      extra: {'count': out.length},
    );
    return out;
  }

  void invalidateCache() {
    _cacheService.invalidate();
  }
}
