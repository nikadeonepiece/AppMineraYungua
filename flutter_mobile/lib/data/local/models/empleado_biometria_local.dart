import 'package:isar/isar.dart';

part 'empleado_biometria_local.g.dart';

@collection
class EmpleadoBiometriaLocal {
  EmpleadoBiometriaLocal();

  Id id = Isar.autoIncrement;
  late int remoteId;

  @Index()
  late int empleadoId;

  @Name('embedding')
  List<double>? embeddingLegacy;
  List<int>? embeddingCipher;
  int embeddingCipherVersion = 1;

  @Name('embeddingDevice')
  List<double>? embeddingDeviceLegacy;
  List<int>? embeddingDeviceCipher;
  int embeddingDeviceCipherVersion = 1;

  late bool activo;
  late DateTime updatedAt;
  DateTime? syncedAt;

  @Index(unique: true, replace: true)
  int get byRemoteId => remoteId;

  @ignore
  List<double> embedding = const [];

  @ignore
  List<double> embeddingDevice = const [];
}
