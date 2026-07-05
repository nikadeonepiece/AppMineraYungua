import 'package:isar/isar.dart';

import '../../../core/database/database_service.dart';
import '../models/empleado_local.dart';

class EmpleadoLocalDatasource {
  EmpleadoLocalDatasource({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;
  Isar get _isar => _databaseService.isar;

  Future<void> upsert(EmpleadoLocal entity) async {
    await _isar.writeTxn(() async {
      await _isar.empleadoLocals.putByByRemoteId(entity);
    });
  }

  Future<void> upsertAll(List<EmpleadoLocal> list) async {
    if (list.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.empleadoLocals.putAllByByRemoteId(list);
    });
  }

  Future<EmpleadoLocal?> getById(int id) => _isar.empleadoLocals.get(id);

  Future<EmpleadoLocal?> getByRemoteId(int remoteId) =>
      _isar.empleadoLocals.getByByRemoteId(remoteId);

  Future<EmpleadoLocal?> getByDni(String dni) async {
    final key = dni.trim();
    if (key.isEmpty) return null;
    final exact = await _isar.empleadoLocals.filter().dniEqualTo(key).findFirst();
    if (exact != null) return exact;
    // Algunos padrones guardan DNI con ceros a la izquierda o espacios.
    final all = await _isar.empleadoLocals.where().findAll();
    for (final e in all) {
      if (e.dni.trim() == key || e.dni.trim().replaceFirst(RegExp(r'^0+'), '') ==
          key.replaceFirst(RegExp(r'^0+'), '')) {
        return e;
      }
    }
    return null;
  }

  Future<EmpleadoLocal?> getByCodigoEmpleado(String codigo) async {
    final key = codigo.trim();
    if (key.isEmpty) return null;
    return _isar.empleadoLocals.filter().codigoEmpleadoEqualTo(key).findFirst();
  }

  Future<List<EmpleadoLocal>> getAll() => _isar.empleadoLocals.where().findAll();

  Future<void> deleteById(int id) async {
    await _isar.writeTxn(() async {
      await _isar.empleadoLocals.delete(id);
    });
  }
}
