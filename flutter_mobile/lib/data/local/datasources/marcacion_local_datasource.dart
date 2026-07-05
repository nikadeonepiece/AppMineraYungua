import 'package:isar/isar.dart';

import '../../../core/database/database_service.dart';
import '../models/marcacion_local.dart';
import '../models/sync_status.dart';

class MarcacionLocalDatasource {
  MarcacionLocalDatasource({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;
  Isar get _isar => _databaseService.isar;

  Future<void> upsert(MarcacionLocal entity) async {
    await _isar.writeTxn(() async {
      await _isar.marcacionLocals.putByUuid(entity);
    });
  }

  Future<void> upsertAll(List<MarcacionLocal> list) async {
    if (list.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.marcacionLocals.putAllByUuid(list);
    });
  }

  Future<MarcacionLocal?> getById(int id) => _isar.marcacionLocals.get(id);
  Future<List<MarcacionLocal>> getAll() => _isar.marcacionLocals.where().findAll();

  Future<List<MarcacionLocal>> getPending({bool includeInBackoff = false}) async {
    final all = await _isar.marcacionLocals
        .filter()
        .group((q) => q.syncStatusEqualTo(SyncStatus.pending).or().syncStatusEqualTo(SyncStatus.failed))
        .sortByCreatedAt()
        .findAll();
    if (includeInBackoff) {
      return all;
    }
    final now = DateTime.now();
    return all
        .where((e) => e.backoffUntil == null || !e.backoffUntil!.isAfter(now))
        .toList(growable: false);
  }

  Future<void> updateSyncStatus(
    String uuid,
    SyncStatus status, {
    int? serverId,
    int? retryCount,
    DateTime? backoffUntil,
    String? lastUploadError,
  }) async {
    final item = await _isar.marcacionLocals.getByUuid(uuid);
    if (item == null) return;
    item.syncStatus = status;
    item.serverId = serverId ?? item.serverId;
    item.retryCount = retryCount ?? item.retryCount;
    item.syncedAt = status == SyncStatus.synced ? DateTime.now() : item.syncedAt;
    if (status == SyncStatus.synced) {
      item.backoffUntil = null;
      item.lastUploadError = '';
    } else {
      if (backoffUntil != null) {
        item.backoffUntil = backoffUntil;
      }
      if (lastUploadError != null) {
        item.lastUploadError = lastUploadError;
      }
    }
    await _isar.writeTxn(() async {
      await _isar.marcacionLocals.put(item);
    });
  }

  Future<void> deleteById(int id) async {
    await _isar.writeTxn(() async {
      await _isar.marcacionLocals.delete(id);
    });
  }
}
