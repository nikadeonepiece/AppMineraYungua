import 'package:isar/isar.dart';

import '../../../core/database/database_service.dart';
import '../models/sync_metadata_local.dart';

class SyncMetadataLocalDatasource {
  SyncMetadataLocalDatasource({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;
  Isar get _isar => _databaseService.isar;

  Future<SyncMetadataLocal> getOrCreate(String entity) async {
    final existing = await _isar.syncMetadataLocals.where().entityEqualTo(entity).findFirst();
    if (existing != null) return existing;
    final metadata = SyncMetadataLocal()..entity = entity;
    await _isar.writeTxn(() async {
      await _isar.syncMetadataLocals.putByEntity(metadata);
    });
    return metadata;
  }

  Future<void> setLastSync(String entity, DateTime value) async {
    final metadata = await getOrCreate(entity);
    metadata.lastSync = value;
    await _isar.writeTxn(() async {
      await _isar.syncMetadataLocals.put(metadata);
    });
  }
}
