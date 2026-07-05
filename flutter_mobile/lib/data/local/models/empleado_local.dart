import 'package:isar/isar.dart';

part 'empleado_local.g.dart';

@collection
class EmpleadoLocal {
  EmpleadoLocal();

  Id id = Isar.autoIncrement;
  late int remoteId;

  /// UUID tal cual en el backend (requerido para subir marcaciones).
  String remoteUuid = '';

  @Index()
  late String dni;

  @Index()
  late String codigoEmpleado;

  late String nombres;
  late String apellidos;
  late String area;
  late String cargo;
  late bool activo;
  late DateTime updatedAt;
  DateTime? syncedAt;

  @Index(unique: true, replace: true)
  int get byRemoteId => remoteId;

  @ignore
  String get nombreCompleto => '$nombres $apellidos'.trim();
}
