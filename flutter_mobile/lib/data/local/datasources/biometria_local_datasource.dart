import 'dart:typed_data';

import 'package:isar/isar.dart';

import '../../../core/database/database_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../security/encryption/embedding_cipher_service.dart';
import '../models/empleado_biometria_local.dart';

class BiometriaLocalDatasource {
  BiometriaLocalDatasource({
    DatabaseService? databaseService,
    EmbeddingCipherService? cipherService,
  })  : _databaseService = databaseService ?? DatabaseService.instance,
        _cipherService = cipherService ?? EmbeddingCipherService();

  final DatabaseService _databaseService;
  final EmbeddingCipherService _cipherService;
  Isar get _isar => _databaseService.isar;

  Future<void> upsert(EmpleadoBiometriaLocal entity) async {
    await _encryptIfNeeded(entity);
    await _isar.writeTxn(() async {
      await _isar.empleadoBiometriaLocals.putByByRemoteId(entity);
    });
  }

  Future<void> upsertAll(List<EmpleadoBiometriaLocal> list) async {
    if (list.isEmpty) return;
    for (final item in list) {
      await _encryptIfNeeded(item);
    }
    await _isar.writeTxn(() async {
      await _isar.empleadoBiometriaLocals.putAllByByRemoteId(list);
    });
  }

  Future<EmpleadoBiometriaLocal?> getById(int id) async {
    final row = await _isar.empleadoBiometriaLocals.get(id);
    if (row == null) return null;
    return _withDecryptedEmbedding(row);
  }

  Future<List<EmpleadoBiometriaLocal>> getAll() async {
    final rows = await _isar.empleadoBiometriaLocals.where().findAll();
    return Future.wait(rows.map(_withDecryptedEmbedding));
  }

  Future<List<EmpleadoBiometriaLocal>> getByEmpleadoId(int empleadoId) async {
    final rows = await _isar.empleadoBiometriaLocals
        .filter()
        .empleadoIdEqualTo(empleadoId)
        .findAll();
    return Future.wait(rows.map(_withDecryptedEmbedding));
  }

  /// Plantilla dispositivo (MobileFaceNet) para marcación offline facial.
  Future<bool> hasStoredDeviceEmbeddingForEmpleado(int empleadoRemoteId) async {
    final rows = await _isar.empleadoBiometriaLocals
        .filter()
        .empleadoIdEqualTo(empleadoRemoteId)
        .activoEqualTo(true)
        .findAll();
    for (final row in rows) {
      final cipherOk = row.embeddingDeviceCipher != null &&
          row.embeddingDeviceCipher!.isNotEmpty;
      final legacyOk = row.embeddingDeviceLegacy != null &&
          row.embeddingDeviceLegacy!.isNotEmpty;
      if (cipherOk || legacyOk) return true;
    }
    return false;
  }

  /// Sin descifrar: plantilla InsightFace o dispositivo.
  Future<bool> hasStoredEmbeddingForEmpleado(int empleadoRemoteId) async {
    if (await hasStoredDeviceEmbeddingForEmpleado(empleadoRemoteId)) {
      return true;
    }
    final rows = await _isar.empleadoBiometriaLocals
        .filter()
        .empleadoIdEqualTo(empleadoRemoteId)
        .activoEqualTo(true)
        .findAll();
    for (final row in rows) {
      final cipherOk =
          row.embeddingCipher != null && row.embeddingCipher!.isNotEmpty;
      final legacyOk =
          row.embeddingLegacy != null && row.embeddingLegacy!.isNotEmpty;
      if (cipherOk || legacyOk) return true;
    }
    return false;
  }

  Future<void> deleteById(int id) async {
    await _isar.writeTxn(() async {
      await _isar.empleadoBiometriaLocals.delete(id);
    });
  }

  Future<int> migrateLegacyEmbeddings() async {
    final rows = await _isar.empleadoBiometriaLocals.where().findAll();
    var migrated = 0;
    for (final row in rows) {
      final hasCipher = row.embeddingCipher != null && row.embeddingCipher!.isNotEmpty;
      final legacy = row.embeddingLegacy ?? const [];
      if (hasCipher || legacy.isEmpty) continue;
      await _encryptIfNeeded(row);
      migrated++;
    }
    if (migrated > 0) {
      await _isar.writeTxn(() async {
        await _isar.empleadoBiometriaLocals.putAll(rows);
      });
      AppLogger.instance.i('Legacy embeddings migrados: $migrated');
    }
    return migrated;
  }

  Future<void> _encryptIfNeeded(EmpleadoBiometriaLocal entity) async {
    final fromRuntime = entity.embedding;
    final fromLegacy = entity.embeddingLegacy ?? const [];
    final source = fromRuntime.isNotEmpty ? fromRuntime : fromLegacy;
    if (source.isNotEmpty) {
      final encrypted = await _cipherService.encryptEmbedding(source);
      entity.embeddingCipher = encrypted.toList(growable: false);
      entity.embeddingCipherVersion = 1;
      entity.embeddingLegacy = null;
      entity.embedding = source;
    }

    final devRuntime = entity.embeddingDevice;
    final devLegacy = entity.embeddingDeviceLegacy ?? const [];
    final devSource =
        devRuntime.isNotEmpty ? devRuntime : devLegacy;
    if (devSource.isNotEmpty) {
      final encryptedDev = await _cipherService.encryptEmbedding(devSource);
      entity.embeddingDeviceCipher = encryptedDev.toList(growable: false);
      entity.embeddingDeviceCipherVersion = 1;
      entity.embeddingDeviceLegacy = null;
      entity.embeddingDevice = devSource;
    }
  }

  Future<EmpleadoBiometriaLocal> _withDecryptedEmbedding(EmpleadoBiometriaLocal entity) async {
    final cipher = entity.embeddingCipher;
    if (cipher != null && cipher.isNotEmpty) {
      entity.embedding = await _cipherService.decryptEmbedding(Uint8List.fromList(cipher));
    } else {
      entity.embedding = entity.embeddingLegacy ?? const [];
    }

    final devCipher = entity.embeddingDeviceCipher;
    if (devCipher != null && devCipher.isNotEmpty) {
      entity.embeddingDevice =
          await _cipherService.decryptEmbedding(Uint8List.fromList(devCipher));
    } else {
      entity.embeddingDevice = entity.embeddingDeviceLegacy ?? const [];
    }
    return entity;
  }
}
