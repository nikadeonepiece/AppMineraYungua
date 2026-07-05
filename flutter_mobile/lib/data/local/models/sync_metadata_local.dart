import 'package:isar/isar.dart';

part 'sync_metadata_local.g.dart';

@collection
class SyncMetadataLocal {
  SyncMetadataLocal();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entity;

  DateTime? lastSync;
}
