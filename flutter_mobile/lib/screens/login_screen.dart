import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/bootstrap/offline_bootstrap.dart';
import '../models/auth_session.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/offline_pin_store.dart';
import '../theme/app_theme.dart';
import '../widgets/connectivity_status_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoggedIn,
  });

  final void Function(AuthSession session) onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController(text: 'admin');
  final _pass = TextEditingController(text: '123456');
  final _pin = TextEditingController();
  final _auth = AuthService();
  final _pinStore = OfflinePinStore();
  StreamSubscription<bool>? _connSub;

  var _loading = false;
  String? _error;
  bool? _online;
  bool? _pinConfigured;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _connSub = OfflineBootstrap.connectivityService.watchOnline().listen((online) {
      if (mounted) setState(() => _online = online);
    });
  }

  Future<void> _bootstrap() async {
    final pinC = await _pinStore.isConfigured;
    final user = await _pinStore.configuredUsername;
    if (user != null && user.isNotEmpty) {
      _user.text = user;
    }
    final online = await OfflineBootstrap.connectivityService.isCurrentlyOnline();
    if (mounted) {
      setState(() {
        _pinConfigured = pinC;
        _online = online;
      });
    }
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _user.dispose();
    _pass.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submitOnline() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await _auth.login(_user.text.trim(), _pass.text);
      widget.onLoggedIn(session);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on SocketException {
      setState(() => _error = 'Sin conexion al servidor. Verifica IP, red y backend.');
    } on TimeoutException {
      setState(() => _error = 'Tiempo de espera agotado al conectar con el servidor.');
    } catch (_) {
      setState(() => _error = 'No se pudo iniciar sesion. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitOfflinePin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await _pinStore.verify(
        username: _user.text.trim(),
        pin: _pin.text,
      );
      if (!ok) {
        setState(() => _error = 'Usuario o PIN incorrecto.');
        return;
      }
      widget.onLoggedIn(AuthSession.offline(username: _user.text.trim()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = _online;
    final pinReady = _pinConfigured;

    if (online == null || pinReady == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final offlineLogin = !online && pinReady;
    final offlineBlocked = !online && !pinReady;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF),
              Colors.white,
              Color(0xFFECFDF5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppBranding.logoAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              AppBranding.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppBranding.primary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const ConnectivityStatusBadge(compact: true),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  offlineLogin ? 'Modo sin conexión' : 'Marcación facial',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppBranding.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  offlineLogin
                      ? 'Ingrese PIN de administrador configurado en este dispositivo.'
                      : offlineBlocked
                          ? 'No hay red. Conéctese al menos una vez como administrador y configure el PIN en el menú (PIN — modo sin conexión).'
                          : 'Inicia sesión para usar la cámara en tiempo real.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 32),
                if (offlineBlocked)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Text(
                        'Sin PIN offline guardado no es posible continuar sin red.',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (offlineLogin) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFDBA74)),
                              ),
                              child: const Text(
                                'INGRESE PIN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9A3412),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: _user,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              helperText: offlineLogin
                                  ? 'Debe coincidir con el administrador que guardó el PIN'
                                  : null,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          if (!offlineLogin) ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: _pass,
                              decoration: const InputDecoration(labelText: 'Contraseña'),
                              obscureText: true,
                              onSubmitted: (_) => _submitOnline(),
                            ),
                          ],
                          if (offlineLogin) ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: _pin,
                              decoration: const InputDecoration(
                                labelText: 'PIN',
                                helperText: 'Solo números, el mismo que configuró en el menú',
                              ),
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onSubmitted: (_) => _submitOfflinePin(),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Color(0xFF9F1239), fontSize: 13),
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          FilledButton(
                            onPressed: _loading
                                ? null
                                : offlineLogin
                                    ? _submitOfflinePin
                                    : _submitOnline,
                            child: Text(
                              _loading
                                  ? 'Ingresando...'
                                  : offlineLogin
                                      ? 'Entrar con PIN'
                                      : 'Ingresar',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
