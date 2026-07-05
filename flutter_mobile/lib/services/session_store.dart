import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _access = 'access_token';
  static const _refresh = 'refresh_token';
  static const _session = 'session_id';
  static String? _memAccess;
  static String? _memRefresh;
  static String? _memSession;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
  }) async {
    _memAccess = accessToken;
    _memRefresh = refreshToken;
    _memSession = sessionId;
    await _storage.write(key: _access, value: accessToken);
    await _storage.write(key: _refresh, value: refreshToken);
    await _storage.write(key: _session, value: sessionId);
  }

  Future<String?> readAccess() async {
    final mem = _memAccess;
    if (mem != null && mem.isNotEmpty) return mem;
    final persisted = await _storage.read(key: _access);
    if (persisted != null && persisted.isNotEmpty) _memAccess = persisted;
    return persisted;
  }

  Future<String?> readRefresh() async {
    final mem = _memRefresh;
    if (mem != null && mem.isNotEmpty) return mem;
    final persisted = await _storage.read(key: _refresh);
    if (persisted != null && persisted.isNotEmpty) _memRefresh = persisted;
    return persisted;
  }

  Future<String?> readSessionId() async {
    final mem = _memSession;
    if (mem != null && mem.isNotEmpty) return mem;
    final persisted = await _storage.read(key: _session);
    if (persisted != null && persisted.isNotEmpty) _memSession = persisted;
    return persisted;
  }

  Future<void> updateAccess(String accessToken) async {
    _memAccess = accessToken;
    await _storage.write(key: _access, value: accessToken);
  }

  Future<void> clear() async {
    _memAccess = null;
    _memRefresh = null;
    _memSession = null;
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
    await _storage.delete(key: _session);
  }

  Future<bool> hasSession() async {
    final a = await readAccess();
    return a != null && a.isNotEmpty;
  }
}
