import '../sync/sync_pull_result.dart';

abstract class EmpleadosRepository {
  Future<SyncPullResult> syncIncremental(DateTime? updatedAfter);
}
