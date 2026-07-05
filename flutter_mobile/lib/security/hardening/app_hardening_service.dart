import 'dart:io';

import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

class AppHardeningService {
  /// `true` = bloquea capturas y grabación de pantalla (FLAG_SECURE en Android).
  /// Temporalmente en `false` para permitir grabar la app; restaurar a `true` en producción.
  static const bool enableSecureScreen = false;

  Future<void> secureScreen() async {
    if (!enableSecureScreen || !Platform.isAndroid) return;
    await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
  }
}
