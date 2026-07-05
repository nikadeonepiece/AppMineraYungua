import '../../data/local/models/marcacion_local.dart';
import '../marcaciones_upload_result.dart';

abstract class MarcacionesRepository {
  Future<void> enqueueMarcacion(MarcacionLocal marcacion);
  /// Si [ignoreRetryLimit] es true, intenta subir todas las pendientes/fallidas aunque hayan superado [maxRetryCount] (sync manual).
  Future<MarcacionesUploadResult> uploadPending({
    required int maxRetryCount,
    bool ignoreRetryLimit = false,
  });
}
