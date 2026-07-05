import 'dart:async';

import 'package:flutter/material.dart';

import 'background/sync_worker.dart';
import 'core/bootstrap/offline_bootstrap.dart';
import 'core/database/database_service.dart';
import 'core/utils/app_logger.dart';
import 'models/auth_session.dart';
import 'screens/home_menu_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'security/security_bootstrap.dart';
import 'security/jwt/jwt_security_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecurityBootstrap.initialize();
  await DatabaseService.instance.initialize();
  await OfflineBootstrap.runLocalSecurityMigrations();
  await SyncWorker.initialize();
  await OfflineBootstrap.connectivityService.initialize();
  runApp(const ControlAsistenciaApp());
}

class ControlAsistenciaApp extends StatefulWidget {
  const ControlAsistenciaApp({super.key});

  @override
  State<ControlAsistenciaApp> createState() => _ControlAsistenciaAppState();
}

class _ControlAsistenciaAppState extends State<ControlAsistenciaApp> with WidgetsBindingObserver {
  final _auth = AuthService();
  final _jwtSecurity = JwtSecurityService();
  AuthSession? _session;
  var _booting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final s = _session;
    if (s == null || s.isOffline) return;
    unawaited(OfflineBootstrap.syncManager.uploadMarcaciones());
  }

  Future<void> _restore() async {
    final s = await _jwtSecurity.ensureValidSession(await _auth.loadSavedSession());
    if (!mounted) return;
    setState(() {
      _session = s;
      _booting = false;
    });
    if (s == null) {
      unawaited(SyncWorker.cancelPeriodicSync());
      return;
    }
    if (s.isOffline) {
      unawaited(SyncWorker.cancelPeriodicSync());
      return;
    }
    unawaited(_uploadPendingMarcacionesInBackground());
    unawaited(SyncWorker.registerPeriodicSync());
  }

  /// No bloquea el splash ni el menú; intenta vaciar la cola si hay red y token válido.
  Future<void> _uploadPendingMarcacionesInBackground() async {
    try {
      final r = await OfflineBootstrap.syncManager.uploadMarcaciones();
      if (r.synced > 0) {
        AppLogger.instance.i('Arranque: ${r.synced} marcación(es) subidas en segundo plano');
      }
    } catch (e, st) {
      AppLogger.instance.w(
        'Arranque: subida de cola omitida o fallida (sin red o servidor)',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBranding.name,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _booting
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _session == null
              ? LoginScreen(
                  onLoggedIn: (s) async {
                    setState(() => _session = s);
                    if (s.isOffline) {
                      await SyncWorker.cancelPeriodicSync();
                      return;
                    }
                    await SyncWorker.registerPeriodicSync();
                    try {
                      await OfflineBootstrap.syncManager.syncAll();
                    } catch (_) {
                      // La app sigue operativa; el usuario puede reintentar sync desde módulos.
                    }
                  },
                )
              : HomeMenuScreen(
                  session: _session!,
                  onSessionUpdated: (s) {
                    setState(() => _session = s);
                    if (s.isOffline) {
                      unawaited(SyncWorker.cancelPeriodicSync());
                    } else {
                      unawaited(SyncWorker.registerPeriodicSync());
                    }
                  },
                  onLogout: () async {
                    final s = _session;
                    try {
                      await SyncWorker.cancelPeriodicSync();
                      if (s != null && !s.isOffline) {
                        await _auth.logout(s).timeout(const Duration(seconds: 5));
                      }
                    } catch (_) {
                      // Si el backend no responde, cerramos localmente igual.
                    } finally {
                      if (mounted) setState(() => _session = null);
                    }
                  },
                ),
    );
  }
}
