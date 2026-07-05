import '../core/utils/app_logger.dart';
import 'anti_spoofing/advanced_anti_spoofing_guard.dart';
import 'audit/device_fingerprint_service.dart';
import 'audit/security_audit_service.dart';
import 'gps_security/gps_security_service.dart';
import 'hardening/app_hardening_service.dart';
import 'root_detection/device_integrity_service.dart';

class SecurityBootstrap {
  SecurityBootstrap._();

  static final DeviceIntegrityService deviceIntegrity = DeviceIntegrityService();
  static final GpsSecurityService gpsSecurity = GpsSecurityService();
  static const AdvancedAntiSpoofingGuard advancedSpoofing = AdvancedAntiSpoofingGuard();
  static final AppHardeningService hardening = AppHardeningService();
  static final DeviceFingerprintService fingerprint = DeviceFingerprintService();

  static Future<void> initialize() async {
    await hardening.secureScreen();
    final integrity = await deviceIntegrity.check();
    final fingerprintMap = await fingerprint.getFingerprint();
    SecurityAuditService.instance.info(
      'security_bootstrap',
      meta: {
        ...fingerprintMap,
        'compromised': integrity.compromised,
        'mock_location': integrity.mockLocation,
      },
    );
    AppLogger.instance.i('Security bootstrap completo');
  }
}
