import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../core/bootstrap/offline_bootstrap.dart';
import '../core/utils/app_logger.dart';
import '../data/local/datasources/empleado_local_datasource.dart';
import '../data/local/models/empleado_local.dart';
import '../models/auth_session.dart';
import '../services/biometric_api.dart';
import '../theme/app_theme.dart';
import '../utils/tts_feedback.dart';

/// Marcación por QR / código de barras (DNI del fotocheck u otro código del trabajador).
class QrAttendanceScreen extends StatefulWidget {
  const QrAttendanceScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final void Function(AuthSession session) onSessionUpdated;
  final Future<void> Function() onLogout;

  @override
  State<QrAttendanceScreen> createState() => _QrAttendanceScreenState();
}

class _QrAttendanceScreenState extends State<QrAttendanceScreen> {
  final _empleadosLocal = EmpleadoLocalDatasource();
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
    ],
  );

  var _busy = false;
  var _torchOn = false;
  String _status = 'Apunte la cámara al código QR o de barras';
  Color _statusColor = const Color(0xFF1565C0);
  final Map<int, DateTime> _cooldownUntil = {};
  int _marcacionCooldownSeconds = kFallbackCooldownSeconds;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted && mounted) {
      setState(() {
        _status = 'Permiso de cámara denegado';
        _statusColor = const Color(0xFFB91C1C);
      });
    }
    if (!widget.session.isOffline && widget.session.accessToken.isNotEmpty) {
      try {
        final cfg = await BiometricApi().fetchConfig(widget.session.accessToken);
        if (!mounted) return;
        setState(() {
          _marcacionCooldownSeconds =
              cfg.duplicateWindowSeconds.clamp(60, 86400);
        });
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    unawaited(TtsFeedback.instance.dispose());
    _controller.dispose();
    super.dispose();
  }

  bool _inCooldown(int empleadoId) {
    final until = _cooldownUntil[empleadoId];
    return until != null && DateTime.now().isBefore(until);
  }

  void _setCooldown(int empleadoId) {
    _cooldownUntil[empleadoId] = DateTime.now().add(
      Duration(seconds: _marcacionCooldownSeconds),
    );
  }

  /// Extrae DNI (o código) desde QR del fotocheck (JSON) o texto plano.
  ({String? dni, String? codigo, String? empleadoUuid}) _parsePayload(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return (dni: null, codigo: null, empleadoUuid: null);

    try {
      final map = jsonDecode(text);
      if (map is Map) {
        final dni = map['dni']?.toString().trim();
        final codigo = map['codigo']?.toString().trim();
        final id = map['id']?.toString().trim();
        return (
          dni: (dni != null && dni.isNotEmpty) ? dni : null,
          codigo: (codigo != null && codigo.isNotEmpty) ? codigo : null,
          empleadoUuid: (id != null && id.isNotEmpty) ? id : null,
        );
      }
    } catch (_) {
      // no es JSON
    }

    // Solo dígitos: DNI / documento
    final digits = text.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^\d{6,12}$').hasMatch(digits)) {
      return (dni: digits, codigo: null, empleadoUuid: null);
    }

    // Código de empleado u otro texto
    return (dni: null, codigo: text, empleadoUuid: null);
  }

  Future<EmpleadoLocal?> _resolveEmpleado(
    ({String? dni, String? codigo, String? empleadoUuid}) parsed,
  ) async {
    if (parsed.dni != null) {
      final byDni = await _empleadosLocal.getByDni(parsed.dni!);
      if (byDni != null) return byDni;
    }
    if (parsed.codigo != null) {
      final byCod = await _empleadosLocal.getByCodigoEmpleado(parsed.codigo!);
      if (byCod != null) return byCod;
    }
    if (parsed.empleadoUuid != null) {
      final all = await _empleadosLocal.getAll();
      for (final e in all) {
        if (e.remoteUuid == parsed.empleadoUuid) return e;
      }
    }
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    _busy = true;
    try {
      final parsed = _parsePayload(raw);
      final emp = await _resolveEmpleado(parsed);
      if (!mounted) return;

      if (emp == null) {
        setState(() {
          _status =
              'Código no reconocido (${parsed.dni ?? parsed.codigo ?? raw}). '
              'Sincronice empleados o verifique el QR.';
          _statusColor = const Color(0xFFB91C1C);
        });
        await Future<void>.delayed(const Duration(seconds: 2));
        return;
      }

      if (!emp.activo) {
        setState(() {
          _status = '${emp.nombreCompleto}: trabajador inactivo';
          _statusColor = const Color(0xFFB45309);
        });
        await Future<void>.delayed(const Duration(seconds: 2));
        return;
      }

      if (_inCooldown(emp.remoteId)) {
        final until = _cooldownUntil[emp.remoteId]!;
        final sec = until.difference(DateTime.now()).inSeconds;
        setState(() {
          _status =
              '${emp.nombreCompleto}: ya registrado. Próxima en ${sec}s';
          _statusColor = const Color(0xFFF59E0B);
        });
        await Future<void>.delayed(const Duration(seconds: 2));
        return;
      }

      setState(() {
        _status = 'Registrando ${emp.nombreCompleto}…';
        _statusColor = const Color(0xFF1565C0);
      });

      await OfflineBootstrap.marcacionService.registrarMarcacion(
        emp.remoteId,
        'entrada',
        metodo: 'qr',
      );
      _setCooldown(emp.remoteId);

      if (!mounted) return;
      setState(() {
        _status =
            '${emp.nombreCompleto} · DNI ${emp.dni} · Marcación QR registrada';
        _statusColor = const Color(0xFF15803D);
      });
      await TtsFeedback.instance.speakMarcacionCorrecta();
      if (!mounted) return;
      await Future<void>.delayed(const Duration(seconds: 2));
    } catch (e, st) {
      AppLogger.instance.e('Error marcación QR', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _status = 'Error al marcar: $e';
        _statusColor = const Color(0xFFB91C1C);
      });
      await Future<void>.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) {
        setState(() {
          _status = 'Apunte la cámara al código QR o de barras';
          _statusColor = const Color(0xFF1565C0);
        });
      }
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcación QR'),
        actions: [
          IconButton(
            tooltip: _torchOn ? 'Apagar linterna' : 'Encender linterna',
            onPressed: () async {
              await _controller.toggleTorch();
              if (!mounted) return;
              setState(() => _torchOn = !_torchOn);
            },
            icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
          ),
          IconButton(
            tooltip: 'Cambiar cámara',
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'El QR del fotocheck incluye el DNI. También se aceptan códigos de barras '
                    'con el número de documento. Requiere catálogo de empleados sincronizado.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _QrFramePainter(color: AppBranding.primary),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrFramePainter extends CustomPainter {
  _QrFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final frameSize = size.shortestSide * 0.68;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final rect = Rect.fromLTWH(left, top, frameSize, frameSize);

    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, hole),
      overlay,
    );

    final border = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      border,
    );

    final cornerLen = frameSize * 0.12;
    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    void cornerAt(Offset o, double dx, double dy) {
      canvas.drawLine(o, o.translate(dx * cornerLen, 0), corner);
      canvas.drawLine(o, o.translate(0, dy * cornerLen), corner);
    }

    cornerAt(rect.topLeft, 1, 1);
    cornerAt(rect.topRight, -1, 1);
    cornerAt(rect.bottomLeft, 1, -1);
    cornerAt(rect.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _QrFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
