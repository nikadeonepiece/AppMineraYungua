import 'package:flutter/material.dart';

import '../core/bootstrap/offline_bootstrap.dart';

/// Indicador En línea / Sin conexión según [ConnectivityService].
class ConnectivityStatusBadge extends StatelessWidget {
  const ConnectivityStatusBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: OfflineBootstrap.connectivityService.watchOnline(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return _pill(
            context,
            label: '…',
            foreground: Colors.blueGrey.shade600,
            icon: Icons.pending_rounded,
          );
        }
        final online = snapshot.data ?? false;
        if (online) {
          return _pill(
            context,
            label: 'Conectado',
            foreground: const Color(0xFF166534),
            icon: Icons.wifi_rounded,
          );
        }
        return _pill(
          context,
          label: 'Sin conexión',
          foreground: const Color(0xFFB45309),
          icon: Icons.cloud_off_rounded,
        );
      },
    );
  }

  Widget _pill(
    BuildContext context, {
    required String label,
    required Color foreground,
    required IconData icon,
  }) {
    final bg = foreground.withValues(alpha: 0.1);
    final border = foreground.withValues(alpha: 0.28);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 15 : 17, color: foreground),
            SizedBox(width: compact ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11.5 : 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
