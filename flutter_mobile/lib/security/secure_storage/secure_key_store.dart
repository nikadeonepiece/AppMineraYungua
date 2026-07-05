import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _isarKey = 'isar_encryption_key_v1';
  static const _embeddingKey = 'embedding_aes_key_v1';

  Future<Uint8List> getOrCreateIsarKey() async {
    final raw = await _storage.read(key: _isarKey);
    if (raw != null && raw.isNotEmpty) {
      return Uint8List.fromList(base64Decode(raw));
    }

    final random = Random.secure();
    final key = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    await _storage.write(key: _isarKey, value: base64Encode(key));
    return key;
  }

  Future<Uint8List> getOrCreateEmbeddingKey() async {
    final raw = await _storage.read(key: _embeddingKey);
    if (raw != null && raw.isNotEmpty) {
      return Uint8List.fromList(base64Decode(raw));
    }

    final random = Random.secure();
    final key = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    await _storage.write(key: _embeddingKey, value: base64Encode(key));
    return key;
  }
}
