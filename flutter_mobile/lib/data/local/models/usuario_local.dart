import 'package:isar/isar.dart';

part 'usuario_local.g.dart';

@collection
class UsuarioLocal {
  UsuarioLocal();

  Id id = Isar.autoIncrement;
  late int remoteId;
  late String username;
  late String passwordHash;
  late int empleadoId;
  late int rolId;
  late bool activo;
  late DateTime updatedAt;
  DateTime? syncedAt;

  @Index(unique: true, replace: true)
  int get byRemoteId => remoteId;
}
