import '../models/auth_session.dart';
import 'api_client.dart';
import 'session_store.dart';

class AuthService {
  AuthService({ApiClient? client, SessionStore? store})
      : _client = client ?? ApiClient(),
        _store = store ?? SessionStore();

  final ApiClient _client;
  final SessionStore _store;

  Future<AuthSession> login(String username, String password) async {
    final data = await _client.postJson(
      '/auth/login',
      body: {'username': username, 'password': password},
    );
    final access = data['access_token'] as String? ?? data['accessToken'] as String?;
    final refresh = data['refresh_token'] as String? ?? data['refreshToken'] as String?;
    final sessionId = data['sessionId'] as String?;
    if (access == null || refresh == null || sessionId == null) {
      throw StateError('Respuesta de login incompleta');
    }
    final usuario = data['usuario'];
    String? uname;
    String? rol;
    if (usuario is Map<String, dynamic>) {
      uname = usuario['username'] as String?;
      rol = usuario['rol'] as String? ?? usuario['nombre_rol'] as String?;
    }
    await _store.save(
      accessToken: access,
      refreshToken: refresh,
      sessionId: sessionId,
      username: uname,
      role: rol,
    );
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      sessionId: sessionId,
      username: uname,
      role: rol,
      isOffline: false,
    );
  }

  Future<AuthSession?> loadSavedSession() async {
    final access = await _store.readAccess();
    final refresh = await _store.readRefresh();
    final sessionId = await _store.readSessionId();
    if (access == null || refresh == null || sessionId == null) return null;
    final username = await _store.readUsername();
    final role = await _store.readRole();
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      sessionId: sessionId,
      username: username,
      role: role,
      isOffline: false,
    );
  }

  Future<String> ensureAccessToken(AuthSession session) async {
    return session.accessToken;
  }

  Future<AuthSession> refreshSession(AuthSession current) async {
    final data = await _client.postJson(
      '/auth/refresh',
      body: {
        'refreshToken': current.refreshToken,
        'sessionId': current.sessionId,
      },
    );
    final access = data['access_token'] as String? ?? data['accessToken'] as String?;
    final refresh = data['refresh_token'] as String? ?? data['refreshToken'] as String?;
    final sessionId = data['sessionId'] as String? ?? current.sessionId;
    if (access == null || refresh == null) {
      throw StateError('Refresh incompleto');
    }
    await _store.save(
      accessToken: access,
      refreshToken: refresh,
      sessionId: sessionId,
      username: current.username,
      role: current.role,
    );
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      sessionId: sessionId,
      username: current.username,
      role: current.role,
      isOffline: false,
    );
  }

  Future<void> logout(AuthSession session) async {
    if (session.isOffline) return;
    try {
      await _client.deleteJson('/auth/logout', bearer: session.accessToken);
    } catch (_) {}
    await _store.clear();
  }
}
