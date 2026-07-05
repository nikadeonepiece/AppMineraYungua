import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../biometric/embeddings/device_embedding_utils.dart';
import '../biometric/embeddings/face_embedding_service.dart';
import '../core/bootstrap/offline_bootstrap.dart';
import '../models/auth_session.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/biometric_api.dart';
import '../utils/front_camera_align.dart';
import '../widgets/connectivity_status_badge.dart';

class EnrollBiometricScreen extends StatefulWidget {
  const EnrollBiometricScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final void Function(AuthSession session) onSessionUpdated;
  final Future<void> Function() onLogout;

  @override
  State<EnrollBiometricScreen> createState() => _EnrollBiometricScreenState();
}

class _EnrollBiometricScreenState extends State<EnrollBiometricScreen> {
  final _auth = AuthService();
  final _api = BiometricApi();
  final _queryCtrl = TextEditingController();
  late AuthSession _session;

  List<Map<String, dynamic>> _results = [];
  Map<String, dynamic>? _selected;
  CameraController? _camera;
  bool _loading = false;
  String? _message;
  final List<Uint8List> _shots = [];
  CameraLensDirection _lens = CameraLensDirection.front;
  bool _selectedHasBiometria = false;
  int _searchNonce = 0;
  var _validatingPair = false;
  String? _pairValidationHint;

  String _employeeIdOf(Map<String, dynamic>? row) {
    if (row == null) return '';
    final byEmpleadoId = row['empleadoId']?.toString().trim() ?? '';
    if (byEmpleadoId.isNotEmpty) return byEmpleadoId;
    return row['id']?.toString().trim() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cams = await availableCameras();
    final cameraDesc = cams.firstWhere(
      (c) => c.lensDirection == _lens,
      orElse: () => cams.first,
    );
    final c = CameraController(cameraDesc, ResolutionPreset.medium, enableAudio: false);
    await c.initialize();
    if (!mounted) {
      await c.dispose();
      return;
    }
    setState(() => _camera = c);
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _search() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final q = _queryCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _message = 'Ingresa nombre, dni o código para buscar.');
      _toast('Ingresa DNI, nombre o código y pulsa Buscar.');
      return;
    }
    final currentNonce = ++_searchNonce;
    setState(() {
      _loading = true;
      _message = 'Buscando…';
    });
    try {
      final fetched = await _api.searchEmployees(_session.accessToken, q);
      if (!mounted) return;
      if (currentNonce != _searchNonce) return;
      setState(() {
        _results = fetched;
        final selectedId = _employeeIdOf(_selected);
        if (selectedId.isNotEmpty) {
          final match = _results.where((r) => _employeeIdOf(r) == selectedId).toList();
          _selected = match.isNotEmpty ? match.first : _selected;
        }
        if (fetched.isEmpty) {
          _message = 'Sin coincidencias para "$q".';
        } else {
          _message = '${fetched.length} resultado(s). Toca uno para seleccionarlo.';
        }
      });
      if (fetched.isEmpty) {
        _toast('Sin resultados para "$q".');
      } else {
        _toast('${fetched.length} resultado(s) para "$q".');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (currentNonce != _searchNonce) return;
      if (e.statusCode == 401) {
        try {
          final s = await _auth.refreshSession(_session);
          _session = s;
          widget.onSessionUpdated(s);
          if (mounted) {
            setState(() => _message = 'Sesión renovada. Repite la búsqueda.');
            _toast('Sesión renovada. Vuelve a pulsar Buscar.');
          }
        } catch (_) {
          if (mounted) await widget.onLogout();
        }
      } else {
        if (mounted) {
          setState(() => _message = e.message);
          _toast(e.message);
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (currentNonce != _searchNonce) return;
      final text = e is TimeoutException
          ? 'Tiempo de espera agotado. Revisa la conexión o que el servidor esté en marcha.'
          : 'No se pudo completar la búsqueda: $e';
      setState(() => _message = text);
      _toast(text);
    } finally {
      if (mounted && currentNonce == _searchNonce) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _captureShot() async {
    if (_selected == null) {
      setState(() => _message = 'Primero selecciona un empleado para registrar fotos.');
      return;
    }
    if (_camera == null || !_camera!.value.isInitialized) return;
    if (_validatingPair) return;
    if (_shots.length >= 5) {
      setState(() => _message = 'Máximo 5 fotos por registro.');
      return;
    }
    final file = await _camera!.takePicture();
    final raw = await file.readAsBytes();
    final bytes = mirrorJpegIfFront(raw, _lens);
    if (!mounted) return;
    setState(() {
      _shots.add(bytes);
      _message = 'Foto ${_shots.length} capturada.';
      _pairValidationHint = null;
    });
    if (_shots.length >= 2) {
      await _validateLastPair();
    }
  }

  /// Compara la captura anterior con la última (InsightFace en servidor).
  Future<void> _validateLastPair() async {
    if (_session.isOffline || _shots.length < 2) return;
    final online = await OfflineBootstrap.connectivityService
        .isOnlineForBiometrics(bearer: _session.accessToken);
    if (!online) {
      if (!mounted) return;
      setState(() {
        _pairValidationHint =
            'Sin conexión al servidor: no se pudo validar el par de fotos. '
            'Conéctese antes de guardar.';
      });
      return;
    }
    setState(() {
      _validatingPair = true;
      _message = 'Validando que las fotos sean de la misma persona…';
    });
    try {
      final prev = _shots[_shots.length - 2];
      final last = _shots[_shots.length - 1];
      final result = await _api.validarParCapturas(
        _session.accessToken,
        jpegA: prev,
        jpegB: last,
      );
      if (!mounted) return;
      final accepted = result['accepted'] == true;
      final score = (result['score'] as num?)?.toDouble();
      final warnings = result['warnings'];
      final warnList = warnings is List
          ? warnings.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : <String>[];
      if (!accepted) {
        setState(() {
          _shots.removeLast();
          _message = result['message']?.toString() ??
              'Las fotos no coinciden. Repita la captura con la misma persona.';
          _pairValidationHint = null;
        });
        _toast(_message!);
        return;
      }
      final scoreTxt = score != null ? ' (sim ${score.toStringAsFixed(2)})' : '';
      setState(() {
        _message = 'Foto ${_shots.length} OK: misma persona confirmada$scoreTxt.';
        _pairValidationHint =
            warnList.isNotEmpty ? warnList.join(' ') : null;
      });
      if (warnList.isNotEmpty) {
        _toast(warnList.first);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        try {
          final s = await _auth.refreshSession(_session);
          _session = s;
          widget.onSessionUpdated(s);
          await _validateLastPair();
          return;
        } catch (_) {
          if (mounted) await widget.onLogout();
          return;
        }
      }
      setState(() {
        _shots.removeLast();
        _message = e.message;
        _pairValidationHint = null;
      });
      _toast(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'No se pudo validar el par de fotos: $e';
        _pairValidationHint = null;
      });
    } finally {
      if (mounted) setState(() => _validatingPair = false);
    }
  }

  Future<void> _saveBiometric() async {
    final empleadoId = _employeeIdOf(_selected);
    if (empleadoId.isEmpty) {
      setState(() => _message = 'Selecciona un trabajador primero.');
      return;
    }
    if (_shots.length < 3) {
      setState(() => _message = 'Debes capturar al menos 3 fotos.');
      return;
    }
    if (!_session.isOffline) {
      final online = await OfflineBootstrap.connectivityService
          .isOnlineForBiometrics(bearer: _session.accessToken);
      if (!online) {
        setState(() => _message =
            'Registro biométrico requiere conexión al servidor. Verifique red y backend.');
        _toast(_message!);
        return;
      }
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      List<double>? embeddingDevice;
      try {
        setState(() => _message = 'Generando plantilla offline (dispositivo)…');
        final embSvc = await FaceEmbeddingService.create();
        embeddingDevice = await embeddingsDesdeJpegsCaptura(_shots, embSvc);
        embSvc.dispose();
      } catch (e) {
        _toast('Plantilla offline no generada: $e. Sincronice tras registrar con red.');
      }
      if (!mounted) return;
      await _api.registerBiometria(
        _session.accessToken,
        empleadoId: empleadoId,
        jpegImages: _shots,
        embeddingDevice: embeddingDevice,
      );
      if (!mounted) return;
      setState(() {
        _message = embeddingDevice != null && embeddingDevice.length >= 16
            ? 'Biometría registrada (online + plantilla offline).'
            : 'Biometría registrada. Re-registre en móvil para habilitar offline facial.';
        _shots.clear();
        _selectedHasBiometria = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _message = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearShots() {
    setState(() {
      _shots.clear();
      _message = 'Fotos limpiadas. Puedes capturar un nuevo set.';
    });
  }

  Future<void> _loadSelectedBiometriaStatus(String empleadoId) async {
    try {
      final status = await _api.fetchBiometriaStatus(_session.accessToken, empleadoId);
      if (!mounted) return;
      setState(() {
        _selectedHasBiometria = status['tieneBiometria'] == true;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        try {
          final s = await _auth.refreshSession(_session);
          _session = s;
          widget.onSessionUpdated(s);
          final status = await _api.fetchBiometriaStatus(_session.accessToken, empleadoId);
          if (!mounted) return;
          setState(() {
            _selectedHasBiometria = status['tieneBiometria'] == true;
          });
        } catch (_) {
          if (mounted) {
            await widget.onLogout();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    final current = _camera;
    if (current != null) {
      await current.dispose();
    }
    setState(() => _camera = null);
    _lens =
        _lens == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;
    await _initCamera();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro biométrico'),
        actions: [
          if (!_session.isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: ConnectivityStatusBadge(compact: true),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: 'Buscar trabajador',
                    hintText: 'DNI, nombres o código',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: _loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                label: const Text('Buscar'),
              ),
            ],
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Resultados',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 8),
          if (_results.isNotEmpty)
            Card(
              child: Column(
                children: _results.map((r) {
                  final id = _employeeIdOf(r);
                  final name = '${r['nombres'] ?? ''} ${r['apellidos'] ?? ''}'.trim();
                  final isSel = _employeeIdOf(_selected) == id;
                  return ListTile(
                    title: Text(name.isEmpty ? id : name),
                    subtitle: Text('DNI: ${r['dni'] ?? '-'} · ID: $id'),
                    trailing: isSel ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    selected: isSel,
                    selectedTileColor: const Color(0xFFE8F5E9),
                    onTap: () {
                      setState(() {
                        _selected = r;
                        _message = 'Empleado seleccionado: ${name.isEmpty ? id : name}';
                        _shots.clear();
                        _selectedHasBiometria = false;
                      });
                      if (id.isNotEmpty) {
                        _loadSelectedBiometriaStatus(id);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          if (_selected != null) ...[
            const SizedBox(height: 10),
            Card(
              color: const Color(0xFFF3F6FB),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Empleado seleccionado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selected?['nombres'] ?? ''} ${_selected?['apellidos'] ?? ''}'.trim(),
                    ),
                    Text('DNI: ${_selected?['dni'] ?? '-'}'),
                    Text('ID: ${_employeeIdOf(_selected).isEmpty ? '-' : _employeeIdOf(_selected)}'),
                    Text(
                      _selectedHasBiometria ? 'Biometría: registrada' : 'Biometría: no registrada',
                      style: TextStyle(
                        color: _selectedHasBiometria ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Captura de fotos (3 a 5)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _camera == null ? null : _switchCamera,
                        icon: const Icon(Icons.cameraswitch_rounded),
                        tooltip: 'Cambiar cámara',
                      ),
                    ],
                  ),
                  const Text(
                    'Una sola persona, rostro centrado y buena luz. Use la misma cámara (frontal o trasera) '
                    'que en marcación facial. Tras la 2.ª foto se valida que sea la misma persona. '
                    'Si usa lentes, mantenga el mismo aspecto al marcar. En el sitio final conviene '
                    'repetir una prueba con la luz real del local.',
                    style: TextStyle(fontSize: 12.5, height: 1.35),
                  ),
                  if (_pairValidationHint != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _pairValidationHint!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: _camera == null || !_camera!.value.isInitialized
                        ? const Center(child: CircularProgressIndicator())
                        : CameraPreview(_camera!),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed:
                            (_loading || _validatingPair || _camera == null) ? null : _captureShot,
                        child: Text(_validatingPair ? 'Validando…' : 'Tomar foto'),
                      ),
                      FilledButton(
                        onPressed: _loading ? null : _saveBiometric,
                        child: const Text('Guardar biometría'),
                      ),
                      if (_selectedHasBiometria)
                        OutlinedButton(
                          onPressed: _shots.isEmpty ? null : _clearShots,
                          child: const Text('Limpiar fotos'),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('Fotos: ${_shots.length}/5'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 10),
            Text(
              _message!,
              style: TextStyle(
                color: _message!.toLowerCase().contains('correct') ? Colors.green.shade700 : Colors.orange.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
