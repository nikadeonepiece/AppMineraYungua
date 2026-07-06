import 'package:flutter/material.dart';

import '../core/bootstrap/offline_bootstrap.dart';
import '../core/utils/app_logger.dart';
import '../data/remote/datasources/sync_areas_remote_datasource.dart';
import '../models/auth_session.dart';
import '../theme/app_theme.dart';

/// Selección de áreas para descargar personal y biometría al dispositivo.
class SyncAreasScreen extends StatefulWidget {
  const SyncAreasScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<SyncAreasScreen> createState() => _SyncAreasScreenState();
}

class _SyncAreasScreenState extends State<SyncAreasScreen> {
  final _areasRemote = SyncAreasRemoteDatasource(OfflineBootstrap.dioClient);
  final _selected = <int>{};

  var _loading = true;
  var _syncing = false;
  String? _error;
  List<SyncAreaItem> _areas = const [];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final areas = await _areasRemote.fetchAreas();
      if (!mounted) return;
      setState(() {
        _areas = areas;
        _loading = false;
        if (areas.length == 1) {
          _selected.add(areas.first.idArea);
        }
      });
    } catch (e, st) {
      AppLogger.instance.e('Error cargando áreas', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _syncSelected() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos un área.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _syncing = true);
    try {
      await OfflineBootstrap.syncManager.syncForAreas(_selected.toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronización por área completada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e, st) {
      AppLogger.instance.e('Sync por áreas fallida', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo sincronizar: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronizar por área'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadAreas,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Elija las áreas cuyo personal desea descargar en este dispositivo '
                        'para marcación offline (QR o facial). También se suben marcaciones pendientes.',
                        style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _areas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final area = _areas[index];
                          final checked = _selected.contains(area.idArea);
                          return Card(
                            child: CheckboxListTile(
                              value: checked,
                              onChanged: _syncing
                                  ? null
                                  : (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selected.add(area.idArea);
                                        } else {
                                          _selected.remove(area.idArea);
                                        }
                                      });
                                    },
                              title: Text(
                                area.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${area.totalPersonal} trabajador(es) en esta área',
                              ),
                              secondary: const CircleAvatar(
                                backgroundColor: Color(0xFFEFF6FF),
                                foregroundColor: AppBranding.primary,
                                child: Icon(Icons.apartment_rounded),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      minimum: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _syncing ? null : _syncSelected,
                          icon: _syncing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_download_rounded),
                          label: Text(
                            _syncing
                                ? 'Sincronizando…'
                                : 'Descargar personal y biometría',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
