import 'package:safe_device/safe_device.dart';

import '../audit/security_audit_service.dart';

class GpsSecurityService {
  Future<bool> isTrustedLocationProvider() async {
    final mocked = await SafeDevice.isMockLocation;
    if (mocked) {
      SecurityAuditService.instance.warn('gps_mock_provider');
    }
    return !mocked;
  }
}
