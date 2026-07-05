import 'dart:convert';

import '../../models/auth_session.dart';
import '../../services/auth_service.dart';
import '../../services/session_store.dart';
import '../audit/security_audit_service.dart';

class JwtSecurityService {
  JwtSecurityService({
    AuthService? authService,
    SessionStore? sessionStore,
  })  : _authService = authService ?? AuthService(),
        _sessionStore = sessionStore ?? SessionStore();

  final AuthService _authService;
  final SessionStore _sessionStore;

  bool isExpired(String jwt, {Duration skew = const Duration(seconds: 30)}) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is! num) return true;
      final expAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
      return DateTime.now().toUtc().isAfter(expAt.subtract(skew));
    } catch (_) {
      return true;
    }
  }

  Future<AuthSession?> ensureValidSession(AuthSession? current) async {
    if (current == null) return null;
    if (current.isOffline) return current;
    if (!isExpired(current.accessToken)) return current;
    try {
      final refreshed = await _authService.refreshSession(current);
      SecurityAuditService.instance.info('jwt_refreshed');
      return refreshed;
    } catch (_) {
      await _sessionStore.clear();
      SecurityAuditService.instance.warn('jwt_refresh_failed_logout');
      return null;
    }
  }
}
