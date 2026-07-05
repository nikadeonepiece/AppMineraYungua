import '../sync/sync_pull_result.dart';

abstract class BiometriaRepository {
  Future<SyncPullResult> syncIncremental(DateTime? updatedAfter);
}
