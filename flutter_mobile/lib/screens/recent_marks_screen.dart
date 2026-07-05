import 'package:flutter/material.dart';

import '../core/bootstrap/offline_bootstrap.dart';
import '../core/network/network_exception.dart';
import '../core/utils/stable_local_id.dart';
import '../data/local/datasources/empleado_local_datasource.dart';
import '../data/local/models/marcacion_local.dart';
import '../data/local/models/sync_status.dart';
import '../models/auth_session.dart';
import '../models/catalog_entry.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/biometric_api.dart';

class RecentMarksScreen extends StatefulWidget {
  const RecentMarksScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final void Function(AuthSession session) onSessionUpdated;
  final Future<void> Function() onLogout;

  @override
  State<RecentMarksScreen> createState() => _RecentMarksScreenState();
}

class _RecentMarksScreenState extends State<RecentMarksScreen> {
  final _auth = AuthService();
  final _api = BiometricApi();
  late AuthSession _session;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  int _pendingUploadCount = 0;
  bool _syncing = false;

  String _formatTimestamp(dynamic raw) {
    final value = raw?.toString();
    if (value == null || value.trim().isEmpty) return '-';
    final dt = DateTime.tryParse(value)?.toLocal();
    if (dt == null) return value;
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min:$ss';
  }

  String _formatMetodo(dynamic metodo) {
    switch (metodo?.toString().toLowerCase()) {
      case 'facial':
        return 'FACIAL';
      case 'dni':
      case 'manual':
        return 'MANUAL';
      case 'qr':
        return 'QR';
      default:
        return metodo?.toString().toUpperCase() ?? '-';
    }
  }

  /// Un solo valor: ENTRADA, SALIDA, etc. (nunca "ENTRADA/SALIDA").
  String _formatTipoEvento(dynamic tipo) {
    switch (tipo?.toString().toLowerCase().trim() ?? '') {
      case 'entrada':
        return 'ENTRADA';
      case 'salida':
        return 'SALIDA';
      case 'refrigerio':
        return 'REFRIGERIO';
      case 'retorno':
        return 'RETORNO';
      default:
        final raw = tipo?.toString().trim() ?? '';
        return raw.isEmpty ? '-' : raw.toUpperCase();
    }
  }

  String _mensajeFalloSubida(String? detalleServidor) {
    final d = detalleServidor?.trim();
    if (d == null || d.isEmpty) {
      return 'No se pudo subir ninguna marcación. Comprueba la red y que el servidor esté en marcha.';
    }
    final corto = d.length > 220 ? '${d.substring(0, 217)}...' : d;
    final lower = d.toLowerCase();
    if (lower.contains('timestamp') || lower.contains('ventana')) {
      return 'El servidor rechazó la hora del envío.\n$corto\n'
          'Si estuvo sin red mucho tiempo, aumente REPLAY_MAX_SKEW_MS en el API y reinicie el servidor.';
    }
    if (lower.contains('firma') || lower.contains('replay')) {
      return 'La firma no coincide con el servidor.\n$corto\n'
          'Use la misma REPLAY_SECRET en el .env del API y al compilar la app (--dart-define).';
    }
    if (lower.contains('dispositivo')) {
      return 'Dispositivo no autorizado en la empresa.\n$corto';
    }
    return 'No se subieron marcaciones.\n$corto';
  }

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _load();
  }

  Future<void> _refreshPendingCount() async {
    final n = await OfflineBootstrap.pendingMarcacionesCount();
    if (mounted) setState(() => _pendingUploadCount = n);
  }

  Future<void> _syncPending() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      await _refreshPendingCount();
      final antes = _pendingUploadCount;
      final result = await OfflineBootstrap.marcacionService.syncMarcacionesPendientes(
        ignoreRetryLimit: true,
      );
      if (!mounted) return;
      await _refreshPendingCount();
      await _load();
      if (!mounted) return;
      final pendientes = _pendingUploadCount;
      if (result.synced > 0) {
        final defer = result.transientDeferred > 0
            ? ' (${result.transientDeferred} aplazada(s) por red; se reintentará sola)'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pendientes > 0
                  ? 'Subidas ${result.synced} marcacion(es). Quedan $pendientes pendiente(s).$defer'
                  : 'Subidas ${result.synced} marcacion(es). Cola vacia.$defer',
            ),
          ),
        );
      } else if (antes > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 10),
            content: Text(_mensajeFalloSubida(result.lastErrorMessage)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No habia marcaciones pendientes.')),
        );
      }
    } on NetworkException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sin red o error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al sincronizar: $e')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _refreshPendingCount();
      if (_session.isOffline) {
        final empleadoLocal = EmpleadoLocalDatasource();
        final empleados = await empleadoLocal.getAll();
        final employeeByRemoteId = <int, String>{
          for (final e in empleados)
            e.remoteId: e.nombreCompleto.isEmpty ? e.dni : e.nombreCompleto,
        };
        final localPending = await OfflineBootstrap.pendingMarcacionesList();
        final localItems = <Map<String, dynamic>>[];
        for (final m in localPending) {
          final id = m.empleadoId;
          final name = employeeByRemoteId[id] ?? 'Empleado #$id';
          localItems.add({
            'timestamp': m.fechaHora.toUtc().toIso8601String(),
            'tipoEvento': m.tipo,
            'metodo': m.metodo,
            'empleadoDisplay': name,
            'origen': 'local',
            'syncStatus': m.syncStatus,
            'localUuid': m.uuid,
            'lastUploadError': m.lastUploadError.trim().isEmpty ? null : m.lastUploadError.trim(),
            'backoffUntil': m.backoffUntil?.toIso8601String(),
          });
        }
        localItems.sort(
          (a, b) => (b['timestamp']?.toString() ?? '')
              .compareTo(a['timestamp']?.toString() ?? ''),
        );
        if (!mounted) return;
        setState(() => _items = localItems);
        return;
      }

      final results = await Future.wait([
        _api.fetchLatestMarks(_session.accessToken),
        _api.fetchCatalog(_session.accessToken),
        OfflineBootstrap.pendingMarcacionesList(),
      ]);
      final rows = results[0] as List<Map<String, dynamic>>;
      final catalog = results[1] as List<CatalogEntry>;
      final localPending = results[2] as List<MarcacionLocal>;
      final employeeById = <String, String>{};
      final employeeByHash = <int, String>{};
      for (final item in catalog) {
        final empleadoId = item.empleadoId.trim();
        if (empleadoId.isEmpty) continue;
        final name = item.displayName.trim();
        final dni = item.dni?.trim() ?? '';
        final display = [
          if (name.isNotEmpty) name,
          if (dni.isNotEmpty) '($dni)',
        ].join(' ');
        final label = display.isEmpty ? empleadoId : display;
        employeeById[empleadoId] = label;
        employeeByHash[stableLocalIdFromRemote(empleadoId)] = label;
      }
      rows.sort(
        (a, b) => (b['timestamp']?.toString() ?? '')
            .compareTo(a['timestamp']?.toString() ?? ''),
      );
      final serverItems = rows.take(50).map((row) {
        final id = row['empleadoId']?.toString().trim() ?? '';
        final fallback = id.isEmpty ? '-' : id;
        return {
          ...row,
          'empleadoDisplay': employeeById[id] ?? fallback,
          'origen': 'servidor',
        };
      }).toList();

      final localItems = <Map<String, dynamic>>[];
      for (final m in localPending) {
        final hash = m.empleadoId;
        final name = employeeByHash[hash] ?? 'Empleado #$hash';
        localItems.add({
          'timestamp': m.fechaHora.toUtc().toIso8601String(),
          'tipoEvento': m.tipo,
          'metodo': 'facial',
          'empleadoDisplay': name,
          'origen': 'local',
          'syncStatus': m.syncStatus,
          'localUuid': m.uuid,
          'lastUploadError': m.lastUploadError.trim().isEmpty ? null : m.lastUploadError.trim(),
          'backoffUntil': m.backoffUntil?.toIso8601String(),
        });
      }
      localItems.sort(
        (a, b) => (b['timestamp']?.toString() ?? '')
            .compareTo(a['timestamp']?.toString() ?? ''),
      );

      if (!mounted) return;
      setState(() {
        _items = [...localItems, ...serverItems];
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        try {
          final s = await _auth.refreshSession(_session);
          _session = s;
          widget.onSessionUpdated(s);
          await _load();
          return;
        } catch (_) {
          if (mounted) await widget.onLogout();
        }
      }
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Últimas marcaciones'),
        actions: [
          IconButton(
            onPressed: (_loading || _syncing || _session.isOffline) ? null : _syncPending,
            tooltip: _session.isOffline
                ? 'Requiere sesión en línea para subir al servidor'
                : 'Subir marcaciones pendientes',
            icon: _syncing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_session.isOffline)
            Material(
              color: const Color(0xFFE0F2FE),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_off_rounded, color: Colors.blue.shade900, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sin conexión al servidor: el listado del backend no está disponible. '
                        'Verá el historial completo en cuanto recupere una red estable e inicie sesión con usuario y contraseña. '
                        'Más abajo solo se muestran las marcaciones almacenadas en este dispositivo.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_pendingUploadCount > 0)
            Material(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$_pendingUploadCount marcacion(es) pendiente(s). Pulse el icono de nube arriba para sincronizar.',
                        style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _items.isEmpty
                        ? const Center(child: Text('Sin marcaciones registradas.'))
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final e = _items[i];
                              final ts = _formatTimestamp(e['timestamp']);
                              final empleado = e['empleadoDisplay']?.toString() ?? '-';
                              final titulo =
                                  '${_formatTipoEvento(e['tipoEvento'])}: ${_formatMetodo(e['metodo'])}';
                              final isLocal = e['origen'] == 'local';
                              final st = e['syncStatus'];
                              var estadoLocal = '';
                              if (isLocal && st is SyncStatus) {
                                estadoLocal = switch (st) {
                                  SyncStatus.pending => ' · Pendiente de subir',
                                  SyncStatus.failed => ' · Error al subir (revisar / sincronizar)',
                                  SyncStatus.syncing => ' · Subiendo…',
                                  SyncStatus.synced => '',
                                };
                              }
                              final err = e['lastUploadError']?.toString().trim();
                              final backoff = e['backoffUntil']?.toString();
                              final extraLocal = (isLocal && (err != null && err.isNotEmpty))
                                  ? '\n$err${backoff != null && backoff.isNotEmpty ? '\nReintento tras: $backoff' : ''}'
                                  : '';
                              return ListTile(
                                leading: Icon(
                                  isLocal ? Icons.phone_android_rounded : Icons.history_toggle_off_rounded,
                                  color: isLocal ? Colors.orange.shade800 : null,
                                ),
                                title: Text('$titulo$estadoLocal'),
                                subtitle: Text('Empleado: $empleado\n$ts$extraLocal'),
                                isThreeLine: true,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
