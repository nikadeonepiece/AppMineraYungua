import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../theme/app_theme.dart';
import '../widgets/connectivity_status_badge.dart';
import 'attendance_modes_screen.dart';
import 'enroll_biometric_screen.dart';
import 'offline_pin_setup_screen.dart';
import 'recent_marks_screen.dart';
import 'sync_areas_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final void Function(AuthSession session) onSessionUpdated;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Asistencia'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Center(
              child: ConnectivityStatusBadge(compact: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: onLogout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          AppBranding.logoAsset,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppBranding.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppBranding.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Selecciona una opción para operar.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  if (session.isOffline) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDBA74)),
                      ),
                      child: Text(
                        'Sesión sin conexión (PIN). Cuando tenga red, cierre sesión e inicie con usuario y contraseña para sincronizar.',
                        style: TextStyle(color: Colors.grey.shade900, fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.sync_rounded,
            title: 'Sincronizar con el servidor',
            subtitle:
                'Elija área(s), descargue personal y biometría; sube marcaciones pendientes.',
            enabled: !session.isOffline,
            disabledMessage:
                'Inicie sesión con usuario y contraseña cuando haya red para sincronizar.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => SyncAreasScreen(session: session),
              ),
            ),
          ),
          if (sessionIsAdmin(session) && !session.isOffline)
            _MenuTile(
              icon: Icons.pin_outlined,
              title: 'PIN — modo sin conexión',
              subtitle:
                  'Añada o cambie el PIN para entrar sin red en este dispositivo (solo administrador).',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OfflinePinSetupScreen(session: session),
                ),
              ),
            ),
          _MenuTile(
            icon: Icons.face_retouching_natural_rounded,
            title: 'Registrar fotos de trabajador',
            subtitle: 'Busca empleado y registra 3-5 fotos para biometría.',
            enabled: !session.isOffline,
            disabledMessage: 'Requiere sesión en línea y conexión al servidor.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EnrollBiometricScreen(
                  session: session,
                  onSessionUpdated: onSessionUpdated,
                  onLogout: onLogout,
                ),
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.how_to_reg_rounded,
            title: 'Registrar asistencia',
            subtitle: 'Elige modo FACE, MANUAL o QR.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AttendanceModesScreen(
                  session: session,
                  onSessionUpdated: onSessionUpdated,
                  onLogout: onLogout,
                ),
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.history_rounded,
            title: 'Últimas marcaciones',
            subtitle: 'Consulta registros recientes reportados por el backend.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecentMarksScreen(
                  session: session,
                  onSessionUpdated: onSessionUpdated,
                  onLogout: onLogout,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.disabledMessage = 'No disponible en modo sin conexión.',
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final String disabledMessage;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFEFF6FF),
            foregroundColor: AppBranding.primary,
            child: Icon(icon),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            if (!enabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(disabledMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            onTap();
          },
        ),
      ),
    );
  }
}
