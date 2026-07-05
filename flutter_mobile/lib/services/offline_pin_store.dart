import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN de administrador para entrar sin red. Solo hash + sal en almacenamiento seguro.
class OfflinePinStore {
  static const _hashKey = 'offline_admin_pin_hash_v1';
  static const _saltKey = 'offline_admin_pin_salt_v1';
  static const _userKey = 'offline_admin_pin_username_v1';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> get isConfigured async {
    final h = await _storage.read(key: _hashKey);
    return h != null && h.isNotEmpty;
  }

  Future<String?> get configuredUsername async {
    final u = await _storage.read(key: _userKey);
    final t = u?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  Future<void> savePin({
    required String adminUsername,
    required String pin,
  }) async {
    final u = adminUsername.trim();
    if (u.isEmpty) throw ArgumentError('Usuario vacío');
    if (pin.length < 4) throw ArgumentError('Use un PIN de al menos 4 dígitos');

    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final hash = _derive(utf8.encode(pin), salt);
    await _storage.write(key: _hashKey, value: _bytesToHex(hash));
    await _storage.write(key: _saltKey, value: _bytesToHex(salt));
    await _storage.write(key: _userKey, value: u.toLowerCase());
  }

  Future<bool> verify({
    required String username,
    required String pin,
  }) async {
    final hexHash = await _storage.read(key: _hashKey);
    final hexSalt = await _storage.read(key: _saltKey);
    final storedUser = await _storage.read(key: _userKey);
    if (hexHash == null || hexSalt == null || storedUser == null) return false;
    if (storedUser.trim().toLowerCase() != username.trim().toLowerCase()) {
      return false;
    }
    final salt = _hexToBytes(hexSalt);
    final expected = _hexToBytes(hexHash);
    final actual = _derive(utf8.encode(pin), salt);
    if (expected.length != actual.length) return false;
    var diff = 0;
    for (var i = 0; i < expected.length; i++) {
      diff |= expected[i] ^ actual[i];
    }
    return diff == 0;
  }

  Future<void> clear() async {
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _userKey);
  }

  List<int> _derive(List<int> passwordBytes, List<int> salt) {
    var acc = sha256.convert([...salt, ...passwordBytes]).bytes;
    for (var i = 0; i < 100000; i++) {
      acc = sha256.convert(acc).bytes;
    }
    return sha256.convert(acc).bytes;
  }

  String _bytesToHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      out.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return out;
  }
}
