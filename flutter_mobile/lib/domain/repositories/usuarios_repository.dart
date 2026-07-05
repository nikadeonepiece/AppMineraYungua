import '../sync/sync_pull_result.dart';

abstract class UsuariosRepository {
  Future<SyncPullResult> syncIncremental(DateTime? updatedAfter);
}
