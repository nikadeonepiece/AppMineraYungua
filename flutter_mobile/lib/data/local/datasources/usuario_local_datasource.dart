import 'package:isar/isar.dart';

import '../../../core/database/database_service.dart';
import '../models/usuario_local.dart';

class UsuarioLocalDatasource {
  UsuarioLocalDatasource({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Isar get _isar => _databaseService.isar;

  Future<void> upsert(UsuarioLocal entity) async {
    await _isar.writeTxn(() async {
      await _isar.usuarioLocals.putByByRemoteId(entity);
    });
  }

  Future<void> upsertAll(List<UsuarioLocal> list) async {
    if (list.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.usuarioLocals.putAllByByRemoteId(list);
    });
  }

  Future<UsuarioLocal?> getById(int id) => _isar.usuarioLocals.get(id);
  Future<List<UsuarioLocal>> getAll() => _isar.usuarioLocals.where().findAll();

  Future<void> deleteById(int id) async {
    await _isar.writeTxn(() async {
      await _isar.usuarioLocals.delete(id);
    });
  }
}
