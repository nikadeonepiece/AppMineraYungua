import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/biometric_api.dart';
import 'face_attendance_screen.dart';
import 'qr_attendance_screen.dart';

class AttendanceModesScreen extends StatefulWidget {
  const AttendanceModesScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final void Function(AuthSession session) onSessionUpdated;
  final Future<void> Function() onLogout;

  @override
  State<AttendanceModesScreen> createState() => _AttendanceModesScreenState();
}

class _AttendanceModesScreenState extends State<AttendanceModesScreen> {
  final _auth = AuthService();
  final _api = BiometricApi();
  late AuthSession _session;
  final _empleadoIdCtrl = TextEditingController();
  var _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  void dispose() {
    _empleadoIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _markManual() async {
    final empleadoId = _empleadoIdCtrl.text.trim();
    if (empleadoId.length != 36) {
      setState(() => _message = 'Empleado ID debe tener 36 caracteres (UUID).');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result = await _api.marcarManual(_session.accessToken, empleadoId);
      if (!mounted) return;
      setState(() => _message = result);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        try {
          final s = await _auth.refreshSession(_session);
          _session = s;
          widget.onSessionUpdated(s);
          if (!mounted) return;
          setState(() => _message = 'Sesión renovada. Reintenta la marcación.');
        } catch (_) {
          if (mounted) await widget.onLogout();
        }
      } else {
        if (!mounted) return;
        setState(() => _message = e.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo de Marcación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEFF6FF),
                foregroundColor: Color(0xFF123D73),
                child: Icon(Icons.face_4_rounded),
              ),
              title: const Text('FACE (reconocimiento facial)'),
              subtitle: const Text(
                'Cámara con detección de rostro y marcación en tiempo real.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FaceAttendanceScreen(
                    session: _session,
                    onSessionUpdated: widget.onSessionUpdated,
                    onLogout: widget.onLogout,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFECFDF5),
                foregroundColor: Color(0xFF15803D),
                child: Icon(Icons.qr_code_scanner_rounded),
              ),
              title: const Text('QR (código QR o de barras)'),
              subtitle: const Text(
                'Escanea el QR del fotocheck (DNI) o un código de barras para marcar asistencia.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QrAttendanceScreen(
                    session: _session,
                    onSessionUpdated: widget.onSessionUpdated,
                    onLogout: widget.onLogout,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MANUAL (UUID)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solo si conoce el empleado_id (UUID) del servidor. Requiere sesión en línea.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _empleadoIdCtrl,
                    enabled: !_session.isOffline,
                    decoration: const InputDecoration(
                      labelText: 'empleado_id',
                      hintText: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: (_loading || _session.isOffline) ? null : _markManual,
                    child: const Text('Marcar MANUAL'),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.toLowerCase().contains('correct')
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
