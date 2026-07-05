import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../core/utils/app_logger.dart';
import '../secure_storage/secure_key_store.dart';
import 'float32_codec.dart';

class EmbeddingCipherService {
  EmbeddingCipherService({
    SecureKeyStore? keyStore,
    Float32Codec? codec,
  })  : _keyStore = keyStore ?? SecureKeyStore(),
        _codec = codec ?? const Float32Codec();

  final SecureKeyStore _keyStore;
  final Float32Codec _codec;
  final AesGcm _algorithm = AesGcm.with256bits();

  SecretKey? _cachedSecret;

  Future<Uint8List> encryptEmbedding(List<double> embedding) async {
    final plain = _codec.encode(embedding);
    final secret = await _secretKey();
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      plain,
      secretKey: secret,
      nonce: nonce,
    );
    final merged = Uint8List(
      nonce.length + box.cipherText.length + box.mac.bytes.length,
    );
    var offset = 0;
    merged.setRange(offset, offset + nonce.length, nonce);
    offset += nonce.length;
    merged.setRange(offset, offset + box.cipherText.length, box.cipherText);
    offset += box.cipherText.length;
    merged.setRange(offset, offset + box.mac.bytes.length, box.mac.bytes);
    return merged;
  }

  Future<List<double>> decryptEmbedding(Uint8List encrypted) async {
    if (encrypted.length < 12 + 16) return const [];
    final nonce = encrypted.sublist(0, 12);
    final mac = encrypted.sublist(encrypted.length - 16);
    final cipherText = encrypted.sublist(12, encrypted.length - 16);
    try {
      final secret = await _secretKey();
      final clear = await _algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: secret,
      );
      return _codec.decode(Uint8List.fromList(clear));
    } catch (e, st) {
      AppLogger.instance.e(
        'Error decrypt embedding',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  Future<SecretKey> _secretKey() async {
    final cached = _cachedSecret;
    if (cached != null) return cached;
    final raw = await _keyStore.getOrCreateEmbeddingKey();
    final secret = SecretKey(raw);
    _cachedSecret = secret;
    return secret;
  }
}
