import 'dart:io';

import 'package:battery_plus/battery_plus.dart';

class ResourceSampler {
  final Battery _battery = Battery();

  Future<int> batteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return -1;
    }
  }

  double currentRssMb() {
    final bytes = ProcessInfo.currentRss;
    return bytes / (1024 * 1024);
  }
}
