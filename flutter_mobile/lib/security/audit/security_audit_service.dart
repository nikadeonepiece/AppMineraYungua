import '../../core/utils/app_logger.dart';

class SecurityAuditService {
  SecurityAuditService._();
  static final SecurityAuditService instance = SecurityAuditService._();

  void info(String event, {Map<String, Object?> meta = const {}}) {
    AppLogger.instance.i('[SECURITY][$event] $meta');
  }

  void warn(String event, {Map<String, Object?> meta = const {}}) {
    AppLogger.instance.w('[SECURITY][$event] $meta');
  }

  void critical(String event, {Map<String, Object?> meta = const {}}) {
    AppLogger.instance.f('[SECURITY][$event] $meta');
  }
}
