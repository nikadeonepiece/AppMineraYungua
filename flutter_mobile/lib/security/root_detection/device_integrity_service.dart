import 'package:safe_device/safe_device.dart';

import '../audit/security_audit_service.dart';

class DeviceIntegrityService {
  Future<IntegrityStatus> check() async {
    final isJailBroken = await SafeDevice.isJailBroken;
    final isRealDevice = await SafeDevice.isRealDevice;
    final isMockLocation = await SafeDevice.isMockLocation;
    final compromised = isJailBroken || !isRealDevice;
    final status = IntegrityStatus(
      compromised: compromised,
      jailBroken: isJailBroken,
      realDevice: isRealDevice,
      mockLocation: isMockLocation,
    );
    if (compromised) {
      SecurityAuditService.instance.critical(
        'device_compromised_detected',
        meta: {
          'jailbroken': isJailBroken,
          'real_device': isRealDevice,
        },
      );
    }
    if (isMockLocation) {
      SecurityAuditService.instance.warn('mock_location_detected');
    }
    return status;
  }
}

class IntegrityStatus {
  IntegrityStatus({
    required this.compromised,
    required this.jailBroken,
    required this.realDevice,
    required this.mockLocation,
  });

  final bool compromised;
  final bool jailBroken;
  final bool realDevice;
  final bool mockLocation;
}
