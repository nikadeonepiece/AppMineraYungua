class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    this.username,
    this.role,
    this.isOffline = false,
  });

  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String? username;
  final String? role;

  /// Acceso solo local (PIN). No hay JWT válido para el API.
  final bool isOffline;

  bool get canRefresh =>
      !isOffline && refreshToken.isNotEmpty && sessionId.isNotEmpty;

  /// Sesión tras validar PIN de administrador (sin persistir tokens en [SessionStore]).
  factory AuthSession.offline({required String username}) {
    return AuthSession(
      accessToken: '',
      refreshToken: '',
      sessionId: 'offline-local',
      username: username,
      role: 'admin',
      isOffline: true,
    );
  }
}
