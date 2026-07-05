import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceFingerprintService {
  Future<Map<String, String>> getFingerprint() async {
    final info = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    String model = 'unknown';
    String os = 'unknown';

    try {
      final android = await info.androidInfo;
      model = android.model;
      os = 'android ${android.version.release}';
    } catch (_) {
      try {
        final ios = await info.iosInfo;
        model = ios.utsname.machine;
        os = 'ios ${ios.systemVersion}';
      } catch (_) {}
    }

    return {
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
      'model': model,
      'os': os,
    };
  }
}
