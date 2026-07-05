import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/models/empleado_biometria_local.dart';
import '../../data/local/models/empleado_local.dart';
import '../../data/local/models/marcacion_local.dart';
import '../../data/local/models/sync_metadata_local.dart';
import '../../data/local/models/usuario_local.dart';
import '../../core/utils/app_logger.dart';
import '../../security/secure_storage/secure_key_store.dart';

class DatabaseService {
  DatabaseService._({SecureKeyStore? keyStore}) : _keyStore = keyStore ?? SecureKeyStore();
  static final DatabaseService instance = DatabaseService._();
  final SecureKeyStore _keyStore;

  Isar? _isar;
  Isar get isar {
    final db = _isar;
    if (db == null) {
      throw StateError('DatabaseService no inicializado');
    }
    return db;
  }

  Future<void> initialize() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    await _keyStore.getOrCreateIsarKey();
    AppLogger.instance.w(
      'Isar 3.1.0+1 no soporta encryptionKey nativo; clave segura preparada para migracion.',
    );
    _isar = await Isar.open(
      [
        UsuarioLocalSchema,
        EmpleadoLocalSchema,
        EmpleadoBiometriaLocalSchema,
        MarcacionLocalSchema,
        SyncMetadataLocalSchema,
      ],
      directory: dir.path,
      name: 'control_asistencia',
    );
  }
}
