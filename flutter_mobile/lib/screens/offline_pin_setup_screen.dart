import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auth_session.dart';
import '../services/offline_pin_store.dart';
import '../theme/app_theme.dart';

bool sessionIsAdmin(AuthSession session) {
  final r = session.role?.trim().toLowerCase() ?? '';
  if (r.isEmpty) return false;
  return r == 'admin' ||
      r == 'administrador' ||
      r == 'superadmin' ||
      r.contains('admin');
}

/// Configurar o cambiar PIN para acceso sin red (solo administrador, con sesión online).
class OfflinePinSetupScreen extends StatefulWidget {
  const OfflinePinSetupScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<OfflinePinSetupScreen> createState() => _OfflinePinSetupScreenState();
}

class _OfflinePinSetupScreenState extends State<OfflinePinSetupScreen> {
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  final _store = OfflinePinStore();
  var _loading = false;
  var _hadPin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await _store.isConfigured;
    if (mounted) setState(() => _hadPin = c);
  }

  @override
  void dispose() {
    _pin.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = _pin.text;
      final p2 = _pin2.text;
      if (p.length < 4) {
        setState(() => _error = 'El PIN debe tener al menos 4 caracteres.');
        return;
      }
      if (p != p2) {
        setState(() => _error = 'Los PIN no coinciden.');
        return;
      }
      final u = widget.session.username?.trim() ?? '';
      if (u.isEmpty) {
        setState(() => _error = 'No hay usuario en la sesión. Vuelva a iniciar sesión.');
        return;
      }
      await _store.savePin(adminUsername: u, pin: p);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN para modo sin conexión guardado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removePin() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar PIN offline'),
        content: const Text(
          'No podrá entrar sin conexión con PIN hasta configurar uno de nuevo estando en línea.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quitar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _store.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN offline eliminado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.isOffline || !sessionIsAdmin(widget.session)) {
      return Scaffold(
        appBar: AppBar(title: const Text('PIN sin conexión')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Solo un administrador con sesión en línea puede configurar el PIN para modo sin conexión.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_hadPin ? 'Cambiar PIN sin conexión' : 'Añadir PIN — modo sin conexión'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'Si el dispositivo pierde la red, podrá iniciar sesión con su usuario de administrador '
            'y este PIN (no se guarda la contraseña del servidor).',
            style: TextStyle(color: Colors.grey.shade800, height: 1.35),
          ),
          const SizedBox(height: 20),
          Text(
            'Administrador: ${widget.session.username ?? "—"}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppBranding.primary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pin,
            decoration: const InputDecoration(
              labelText: 'PIN',
              helperText: 'Mínimo 4 caracteres (solo este dispositivo)',
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pin2,
            decoration: const InputDecoration(labelText: 'Confirmar PIN'),
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: Text(_loading ? 'Guardando…' : 'Guardar PIN'),
          ),
          if (_hadPin) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loading ? null : _removePin,
              child: const Text('Quitar PIN offline'),
            ),
          ],
        ],
      ),
    );
  }
}
