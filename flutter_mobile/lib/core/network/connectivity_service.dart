import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../data/sync/sync_manager.dart';
import '../utils/app_logger.dart';

class ConnectivityService {
  ConnectivityService(this._syncManager, {Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final SyncManager _syncManager;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  DateTime? _apiCheckedAt;
  bool? _apiReachable;

  /// Solo cambios de interfaz (sin valor inicial). Preferir [watchOnline] en UI.
  Stream<bool> get isOnlineStream => _connectivity.onConnectivityChanged.map(
        (results) => !results.contains(ConnectivityResult.none),
      );

  /// Emite el estado actual al suscribirse y luego cada cambio de red.
  Stream<bool> watchOnline() async* {
    yield await isCurrentlyOnline();
    await for (final results in _connectivity.onConnectivityChanged) {
      yield !results.contains(ConnectivityResult.none);
    }
  }

  Future<bool> isCurrentlyOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  /// Comprueba que el API Nest responda (no solo Wi‑Fi/datós activos).
  Future<bool> isBackendReachable({
    required String bearer,
    Duration cacheFor = const Duration(seconds: 10),
  }) async {
    if (!await isCurrentlyOnline()) {
      _apiReachable = false;
      return false;
    }
    final now = DateTime.now();
    if (_apiCheckedAt != null &&
        now.difference(_apiCheckedAt!) < cacheFor &&
        _apiReachable != null) {
      return _apiReachable!;
    }
    try {
      final base = kApiBase.replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/empleados/biometria/config').replace(
        queryParameters: {'dispositivo_id': kDeviceId},
      );
      final res = await http
          .get(
            uri,
            headers: {'Authorization': 'Bearer $bearer'},
          )
          .timeout(const Duration(seconds: 4));
      _apiReachable = res.statusCode >= 200 && res.statusCode < 500;
    } catch (_) {
      _apiReachable = false;
    }
    _apiCheckedAt = now;
    return _apiReachable!;
  }

  /// Enlace activo y backend alcanzable (modo biométrico en línea).
  Future<bool> isOnlineForBiometrics({required String bearer}) async {
    if (!await isCurrentlyOnline()) return false;
    if (bearer.isEmpty) return false;
    return isBackendReachable(bearer: bearer);
  }

  /// Emite cuando cambia el enlace o la reachability del API (con token).
  Stream<bool> watchOnlineForBiometrics(String bearer) async* {
    yield await isOnlineForBiometrics(bearer: bearer);
    await for (final linkUp in watchOnline()) {
      if (!linkUp) {
        _apiReachable = false;
        yield false;
        continue;
      }
      yield await isBackendReachable(bearer: bearer);
    }
  }

  void invalidateApiReachabilityCache() {
    _apiCheckedAt = null;
    _apiReachable = null;
  }

  Future<void> initialize() async {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final online = !results.contains(ConnectivityResult.none);
      if (!online) return;
      AppLogger.instance.i('Conectividad recuperada, iniciando syncAll');
      try {
        await _syncManager.syncAll();
      } catch (e, st) {
        AppLogger.instance.e('Error ejecutando syncAll tras reconexion', error: e, stackTrace: st);
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
