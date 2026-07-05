import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../biometric/detection/face_detector_service.dart';
import '../biometric/embeddings/face_embedding_service.dart';
import '../biometric/matching/local_catalog_service.dart';
import '../biometric/matching/local_face_candidate.dart';
import '../config/app_config.dart';
import '../core/bootstrap/offline_bootstrap.dart';
import '../core/network/network_exception.dart';
import '../data/remote/models/biometria_match_from_image_result.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/stable_local_id.dart';
import '../models/auth_session.dart';
import '../optimization/indexing/embedding_prefilter_index.dart';
import '../optimization/performance/performance_monitor.dart';
import '../security/security_bootstrap.dart';
import '../services/biometric_api.dart';
import '../utils/biometric_image_encode.dart';
import '../utils/camera_image_utils.dart';
import '../utils/embedding_math.dart';
import '../utils/face_crop_utils.dart';
import '../utils/front_camera_align.dart';
import '../widgets/connectivity_status_badge.dart';

class FaceAttendanceScreen extends StatefulWidget {
  const FaceAttendanceScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final void Function(AuthSession session) onSessionUpdated;
  final Future<void> Function() onLogout;

  @override
  State<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceUi {
  _FaceUi({required this.color, required this.label});

  final Color color;
  final String label;
}

class _PrimaryFaceCandidate {
  const _PrimaryFaceCandidate({
    required this.face,
    required this.trackId,
    required this.score,
  });

  final Face face;
  final int trackId;
  final double score;
}

class _FaceAttendanceScreenState extends State<FaceAttendanceScreen> {
  // Reconocimiento simple: ML Kit + TFLite + coseno vs catálogo completo (sin capa IA extra).

  final _detector = FaceDetectorService();
  final _catalogService = LocalCatalogService();
  FaceEmbeddingService? _embeddingService;

  CameraController? _camera;

  var _camBusy = false;
  var _catalogLoading = true;
  String? _loadError;
  var _securityBlocked = false;
  var _fps = 0.0;
  var _frameCounter = 0;
  var _lastFpsTick = DateTime.now();
  var _comparisonMs = 0;
  var _inferenceMs = 0;
  var _syncMs = 0;
  var _frameSkip = 2;
  var _incomingFrameCount = 0;

  List<LocalFaceCandidate> _catalog = [];
  List<LocalFaceCandidate> _catalogDevice = [];
  final _prefilterIndex = EmbeddingPrefilterIndex();

  /// Offline: mismo espacio MobileFaceNet (`embedding_device`).
  static const double _deviceMinCosine = 0.48;
  static const double _deviceMinMargin = 0.04;
  static const double _deviceMinCosineToMark = 0.52;
  static const double _deviceMinCosineToShowName = 0.50;
  static const int _devicePrefilterMax = 350;

  /// Umbral mínimo de coseno (catálogo InsightFace vs TFLite móvil → scores bajos y poco comparables).
  static const double _simpleMinCosine = 0.10;

  /// Si hay 2+ personas, exigir separación mínima entre 1.º y 2.º (evita empates).
  static const double _simpleMinMargin = 0.005;

  /// Con separación clara 1.º vs 2.º, aceptar cosenos más bajos (mismo desalineamiento de modelos).
  static const double _simpleStrongSeparation = 0.035;
  static const double _simpleMinCosineIfSeparated = 0.055;

  /// Ultimo fallback: solo con separación razonable y estabilidad alta entre frames.
  static const double _simpleUltraLowMinSeparation = 0.020;
  static const double _simpleUltraLowCosine = 0.020;

  /// Score servidor (InsightFace) alto: menos frames de estabilidad.
  static const double _serverScoreFastStable = 0.62;
  static const int _embedMinIntervalMs = 1000;
  int _marcacionCooldownSeconds = kFallbackCooldownSeconds;

  /// Tras registrar, unos segundos en verde antes de pasar a amarillo (ventana anti-duplicado).
  static const int _successGreenFlashSeconds = 4;
  static const int _primaryTrackAcquireFrames = 2;
  static const int _activeTrackGraceMs = 450;
  static const double _primaryTrackSwitchMargin = 0.12;
  /// Tras espejar el recorte frontal ya no hace falta desplazar el ROI (evitaba cuadro corrido).
  static const double _frontLensHorizontalCenterShiftFactor = 0.0;
  List<Face> _faces = [];
  Size _imageSize = Size.zero;

  final Map<int, _FaceUi> _uiByTrack = {};
  final Map<int, DateTime> _lastEmbedByTrack = {};
  final Map<int, DateTime> _cooldownUntil = {};

  /// Tras una marcación OK, breve mensaje en verde por empleado (hash local).
  final Map<int, DateTime> _successGreenUntil = {};
  final Map<int, int> _lastEmpByTrack = {};
  final Map<int, int> _sameEmpCountByTrack = {};
  final Map<int, int> _visibleFrameCountByTrack = {};
  int? _activeTrackId;
  DateTime? _activeTrackLastSeenAt;

  /// Solo la inferencia TFLite no es reentrante; la llamada al servidor no debe bloquear nuevos intentos.
  var _tfliteInferBusy = false;
  CameraLensDirection _lens = CameraLensDirection.front;
  String _detectStatus = 'Inicializando...';

  /// Backend alcanzable con sesión online (prioridad modo en línea).
  var _networkAvailable = true;
  StreamSubscription<bool>? _networkModeSub;

  @override
  void initState() {
    super.initState();
    _bindNetworkModeWatcher();
    _init();
  }

  void _bindNetworkModeWatcher() {
    _networkModeSub?.cancel();
    if (widget.session.isOffline || widget.session.accessToken.isEmpty) {
      _networkAvailable = false;
      return;
    }
    _networkModeSub = OfflineBootstrap.connectivityService
        .watchOnlineForBiometrics(widget.session.accessToken)
        .listen((online) {
      if (!mounted) return;
      setState(() => _networkAvailable = online);
    });
  }

  Future<void> _init() async {
    await _checkSecurityPreconditions();
    await _loadBiometriaCooldownFromServer();
    await _syncAndReloadCatalog();
    if (!_securityBlocked) {
      await _initCameraAndDetector();
    }
  }

  /// Misma ventana que `biometria_config` + asistencia en servidor (piso local al fallback).
  Future<void> _loadBiometriaCooldownFromServer() async {
    if (widget.session.isOffline || widget.session.accessToken.isEmpty) {
      return;
    }
    try {
      final cfg = await BiometricApi().fetchConfig(widget.session.accessToken);
      if (!mounted) return;
      final seconds = math
          .max(cfg.duplicateWindowSeconds, kFallbackCooldownSeconds)
          .clamp(60, 86400)
          .toInt();
      setState(() => _marcacionCooldownSeconds = seconds);
    } catch (e, st) {
      AppLogger.instance.d(
        'Cooldown marcacion: se usa valor local',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _checkSecurityPreconditions() async {
    final integrity = await SecurityBootstrap.deviceIntegrity.check();
    final gpsTrusted =
        await SecurityBootstrap.gpsSecurity.isTrustedLocationProvider();
    if (!mounted) return;
    if (integrity.compromised || !gpsTrusted) {
      setState(() {
        _securityBlocked = true;
        _loadError = integrity.compromised
            ? 'Dispositivo inseguro detectado. Marcacion bloqueada.'
            : 'GPS no confiable (mock location). Marcacion bloqueada.';
      });
    }
  }

  Future<void> _loadCatalogAndModel() async {
    setState(() {
      _catalogLoading = true;
      _loadError = null;
    });
    try {
      _embeddingService?.dispose();
      _embeddingService = await FaceEmbeddingService.create();
      final catalog = await _catalogService.loadCandidates();
      final catalogDevice = await _catalogService.loadDeviceCandidates();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _catalogDevice = catalogDevice;
        _catalogLoading = false;
      });
    } catch (e) {
      AppLogger.instance.e('Error cargando catalogo/modelo local', error: e);
      if (mounted) {
        setState(() {
          _catalogLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  Future<void> _retryAll() async {
    await _syncAndReloadCatalog();
    if (!mounted || _securityBlocked) return;
    if (_camera == null || !_camera!.value.isInitialized) {
      await _initCameraAndDetector();
    }
  }

  Future<void> _syncAndReloadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _loadError = null;
    });
    try {
      await OfflineBootstrap.syncManager.syncAll();
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = 'Error al sincronizar: $e');
      }
    }
    await _loadCatalogAndModel();
  }

  Future<void> _initCameraAndDetector() async {
    final camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) {
      if (mounted) {
        setState(() => _loadError = 'Permiso de camara denegado');
      }
      return;
    }

    final cams = await availableCameras();
    final chosen = cams.firstWhere(
      (c) => c.lensDirection == _lens,
      orElse: () => cams.first,
    );

    // Misma nitidez que el registro biométrico (medium) en ambas lentes.
    final preset = _catalog.length > 3000
        ? ResolutionPreset.low
        : ResolutionPreset.medium;

    final controller = CameraController(
      chosen,
      preset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _camera = controller;
      _frameSkip = chosen.lensDirection == CameraLensDirection.back ? 3 : 2;
    });

    await controller.startImageStream(_processCameraImage);
  }

  Future<void> _switchCamera() async {
    final current = _camera;
    if (current != null && current.value.isStreamingImages) {
      await current.stopImageStream();
    }
    await current?.dispose();
    _camera = null;
    _resetPrimaryTracking();
    setState(() {
      _lens = _lens == CameraLensDirection.front
          ? CameraLensDirection.back
          : CameraLensDirection.front;
      _detectStatus = 'Cambiando cámara...';
    });
    await _initCameraAndDetector();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_camBusy || _camera == null || !mounted) return;
    if (_catalog.isEmpty && !_catalogLoading) return;
    _incomingFrameCount++;
    if (_incomingFrameCount % _frameSkip != 0) return;

    _camBusy = true;
    try {
      final faces = await _detector.detect(image, _camera!);
      if (!mounted) return;
      _countFps();
      final now = DateTime.now();
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final areaMin = image.width * image.height * 0.03;
      final eligibleFaces = faces.where((face) {
        final b = face.boundingBox;
        return b.width * b.height >= areaMin;
      }).toList(growable: false);
      final primary = _selectPrimaryFace(eligibleFaces, imageSize, now);

      setState(() {
        _faces = eligibleFaces;
        _imageSize = imageSize;
        _detectStatus = _buildDetectStatus(
          detectedCount: faces.length,
          eligibleCount: eligibleFaces.length,
          primary: primary,
          now: now,
        );
      });

      if (primary == null) {
        return;
      }

      final last = _lastEmbedByTrack[primary.trackId];
      if (last != null &&
          now.difference(last).inMilliseconds < _embedMinIntervalMs) {
        return;
      }
      _lastEmbedByTrack[primary.trackId] = now;

      unawaited(_recognizeFace(image, primary.face, primary.trackId));
    } catch (e) {
      if (mounted) {
        setState(() => _detectStatus = 'Error de detección: $e');
      }
    } finally {
      _camBusy = false;
    }
  }

  bool _inCooldown(int empleadoId, DateTime now) {
    final until = _cooldownUntil[empleadoId];
    return until != null && now.isBefore(until);
  }

  void _setCooldown(int empleadoId, int seconds) {
    final until = DateTime.now().add(Duration(seconds: seconds));
    final prev = _cooldownUntil[empleadoId];
    if (prev == null || until.isAfter(prev)) {
      _cooldownUntil[empleadoId] = until;
    }
  }

  String _formatCooldownRemaining(DateTime until, DateTime now) {
    final totalSecs =
        until.difference(now).inSeconds.clamp(0, _marcacionCooldownSeconds);
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  int _trackIdForFace(Face face) {
    final b = face.boundingBox;
    return face.trackingId ?? Object.hash(b.left.round(), b.top.round());
  }

  void _resetPrimaryTracking() {
    _activeTrackId = null;
    _activeTrackLastSeenAt = null;
    _visibleFrameCountByTrack.clear();
  }

  bool _hasRecentActiveTrack(DateTime now) {
    final lastSeen = _activeTrackLastSeenAt;
    return _activeTrackId != null &&
        lastSeen != null &&
        now.difference(lastSeen).inMilliseconds < _activeTrackGraceMs;
  }

  double _scorePrimaryFace(Face face, Size imageSize,
      {required bool isActiveTrack}) {
    final b = face.boundingBox;
    final imageArea = math.max(1.0, imageSize.width * imageSize.height);
    final areaScore =
        ((b.width * b.height) / imageArea).clamp(0.0, 1.0).toDouble();

    final halfW = imageSize.width <= 0 ? 1.0 : imageSize.width / 2;
    final halfH = imageSize.height <= 0 ? 1.0 : imageSize.height / 2;
    final dx = (b.center.dx - imageSize.width / 2) / halfW;
    final dy = (b.center.dy - imageSize.height / 2) / halfH;
    final dist = math.sqrt(dx * dx + dy * dy);
    final centerScore = (1.0 - (dist / math.sqrt2)).clamp(0.0, 1.0).toDouble();

    var score = areaScore * 0.65 + centerScore * 0.35;
    if (isActiveTrack) {
      score += 0.45;
    }
    return score;
  }

  _PrimaryFaceCandidate? _selectPrimaryFace(
    List<Face> faces,
    Size imageSize,
    DateTime now,
  ) {
    final candidates = faces
        .map(
          (face) => _PrimaryFaceCandidate(
            face: face,
            trackId: _trackIdForFace(face),
            score: _scorePrimaryFace(
              face,
              imageSize,
              isActiveTrack: _activeTrackId == _trackIdForFace(face),
            ),
          ),
        )
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final visibleTrackIds =
        candidates.map((candidate) => candidate.trackId).toSet();
    _visibleFrameCountByTrack
        .removeWhere((trackId, _) => !visibleTrackIds.contains(trackId));
    for (final candidate in candidates) {
      _visibleFrameCountByTrack[candidate.trackId] =
          (_visibleFrameCountByTrack[candidate.trackId] ?? 0) + 1;
    }

    if (candidates.isEmpty) {
      if (!_hasRecentActiveTrack(now)) {
        _resetPrimaryTracking();
      }
      return null;
    }

    final currentActiveId = _activeTrackId;
    if (currentActiveId != null) {
      for (final candidate in candidates) {
        if (candidate.trackId == currentActiveId) {
          _activeTrackLastSeenAt = now;
          return candidate;
        }
      }
    }

    if (!_hasRecentActiveTrack(now)) {
      _activeTrackId = null;
      _activeTrackLastSeenAt = null;
    }

    final best = candidates.first;
    final bestVisibleFrames = _visibleFrameCountByTrack[best.trackId] ?? 0;
    final secondScore = candidates.length > 1 ? candidates[1].score : -1.0;
    final bestClearlyAhead = secondScore < 0 ||
        (best.score - secondScore) >= _primaryTrackSwitchMargin;

    if (_hasRecentActiveTrack(now) && !bestClearlyAhead) {
      return null;
    }
    if (bestVisibleFrames < _primaryTrackAcquireFrames) {
      return null;
    }

    _activeTrackId = best.trackId;
    _activeTrackLastSeenAt = now;
    return best;
  }

  String _buildDetectStatus({
    required int detectedCount,
    required int eligibleCount,
    required _PrimaryFaceCandidate? primary,
    required DateTime now,
  }) {
    if (detectedCount == 0) {
      return 'Sin rostro detectado';
    }
    if (eligibleCount == 0) {
      return detectedCount == 1
          ? 'Rostro detectado, pero muy lejos'
          : 'Rostros detectados, pero muy lejos';
    }
    if (primary == null) {
      if (_hasRecentActiveTrack(now)) {
        return eligibleCount > 1
            ? 'Manteniendo rostro principal ante multiples rostros...'
            : 'Recuperando rostro principal...';
      }
      return eligibleCount > 1
          ? 'Seleccionando rostro principal...'
          : 'Estabilizando rostro principal...';
    }
    if (eligibleCount > 1) {
      return 'Rostro principal fijado · secundarios ignorados';
    }
    return 'Rostro principal detectado';
  }

  double _roiHorizontalCenterShiftFactor(CameraLensDirection lensDirection) {
    return lensDirection == CameraLensDirection.front
        ? _frontLensHorizontalCenterShiftFactor
        : 0.0;
  }

  void _resetRecognitionStateForTrack(int trackId) {
    _lastEmpByTrack.remove(trackId);
    _sameEmpCountByTrack.remove(trackId);
  }

  String _labelForServerMatchRejection(BiometriaMatchFromImageResult r) {
    switch (r.outcome) {
      case BiometriaMatchFromImageOutcome.noMatch:
        return 'Servidor: sin coincidencia suficiente';
      case BiometriaMatchFromImageOutcome.ambiguous:
        return 'Servidor: coincidencia ambigua';
      case BiometriaMatchFromImageOutcome.endpointRejected:
        final m = r.message?.trim();
        if (m != null && m.isNotEmpty) return 'Servidor: $m';
        return 'Servidor: no se pudo validar el rostro';
      case BiometriaMatchFromImageOutcome.transportOrUpstream:
      case BiometriaMatchFromImageOutcome.success:
        break;
    }
    return r.message ?? 'Error al validar con el servidor';
  }

  Color _colorForServerMatchRejection(BiometriaMatchFromImageOutcome o) {
    if (o == BiometriaMatchFromImageOutcome.endpointRejected) {
      return const Color(0xFFFF9800);
    }
    return const Color(0xFFE53935);
  }

  bool _isStableIdentity(int trackId, int empleadoId,
      {required int minFrames}) {
    final prev = _lastEmpByTrack[trackId];
    if (prev == empleadoId) {
      _sameEmpCountByTrack[trackId] = (_sameEmpCountByTrack[trackId] ?? 0) + 1;
    } else {
      _lastEmpByTrack[trackId] = empleadoId;
      _sameEmpCountByTrack[trackId] = 1;
    }
    return (_sameEmpCountByTrack[trackId] ?? 0) >= minFrames;
  }

  int _requiredStableFrames(double score) {
    if (score >= _simpleMinCosine) return 2;
    if (score >= _simpleMinCosineIfSeparated) return 3;
    return 6;
  }

  int _serverStableFrames(double score) {
    if (score >= _serverScoreFastStable) return 1;
    return 2;
  }

  /// Sesión con token y API alcanzable: identidad solo vía InsightFace en servidor.
  bool get _requiresServerMatch =>
      !widget.session.isOffline &&
      widget.session.accessToken.isNotEmpty &&
      _networkAvailable;

  /// Modo degradado: sesión online pero sin red/API; comparación local temporal.
  bool get _degradedOfflineMode =>
      !widget.session.isOffline &&
      widget.session.accessToken.isNotEmpty &&
      !_networkAvailable;

  /// Mejor y segundo mejor candidato por coseno (O(N); con miles de plantillas valorar ANN/HNSW).
  ({LocalFaceCandidate? best, double bestScore, double secondScore})
      _bestTwoSimple(
    List<double> query,
    List<LocalFaceCandidate> catalog,
  ) {
    LocalFaceCandidate? best;
    var bestS = -1.0;
    var secondS = -1.0;
    for (final c in catalog) {
      final s = cosineSimilarity(query, c.embedding);
      if (s > bestS) {
        secondS = bestS;
        bestS = s;
        best = c;
      } else if (s > secondS) {
        secondS = s;
      }
    }
    return (best: best, bestScore: bestS, secondScore: secondS);
  }

  Future<void> _recognizeFace(CameraImage image, Face face, int trackId) async {
    if (_securityBlocked || _embeddingService == null) {
      return;
    }
    if (_catalogDevice.isEmpty && _catalog.isEmpty) {
      return;
    }

    try {
      final expanded = expandFaceRectForEmbedding(
        face.boundingBox,
        image.width,
        image.height,
        horizontalCenterShiftFactor: _roiHorizontalCenterShiftFactor(
          _camera!.description.lensDirection,
        ),
      );
      var left = expanded.left.floor();
      var cropTop = expanded.top.floor();
      var right = expanded.right.ceil();
      var bottom = expanded.bottom.ceil();
      left = left.clamp(0, image.width - 1);
      cropTop = cropTop.clamp(0, image.height - 1);
      right = right.clamp(0, image.width);
      bottom = bottom.clamp(0, image.height);
      if (right <= left || bottom <= cropTop) return;

      final cropW = right - left;
      final cropH = bottom - cropTop;

      var rgbCrop = cameraImageRoiToRgbImage(
        image,
        left: left,
        top: cropTop,
        width: cropW,
        height: cropH,
      );
      rgbCrop = mirrorRgbIfFront(
        rgbCrop,
        _camera!.description.lensDirection,
      );
      if (rgbCrop == null) return;

      final now = DateTime.now();
      LocalFaceMatch? match;
      var matchFromServer = false;
      var matchFromDevice = false;
      var top = (
        best: null as LocalFaceCandidate?,
        bestScore: -1.0,
        secondScore: -1.0,
      );
      var multi = false;
      var ambiguous = false;

      if (_tfliteInferBusy) return;
      _tfliteInferBusy = true;
      List<double> embedding;
      try {
        PerformanceMonitor.instance.start('embedding_inference');
        embedding = _embeddingService!.generateEmbedding(rgbCrop);
        _inferenceMs = PerformanceMonitor.instance.stop('embedding_inference');
      } finally {
        _tfliteInferBusy = false;
      }

      final skipServer = widget.session.isOffline ||
          widget.session.accessToken.isEmpty ||
          !_networkAvailable;

      List<LocalFaceCandidate> comparePool = _catalogDevice;
      if (comparePool.isEmpty) {
        comparePool = _catalog;
      }
      if (comparePool.length > _devicePrefilterMax) {
        comparePool =
            _prefilterIndex.prefilter(embedding, comparePool, maxCandidates: _devicePrefilterMax);
      }
      multi = comparePool.length >= 2;

      PerformanceMonitor.instance.start('embedding_compare');
      top = _bestTwoSimple(embedding, comparePool);
      final sepPre = top.bestScore - top.secondScore;
      final useDeviceSpace = _catalogDevice.isNotEmpty;
      final minMargin =
          useDeviceSpace ? _deviceMinMargin : _simpleMinMargin;
      ambiguous = multi && top.secondScore > -1 && sepPre < minMargin;
      _comparisonMs = PerformanceMonitor.instance.stop(
        'embedding_compare',
        extra: {
          'candidates': comparePool.length,
          'best': top.bestScore,
          'second': top.secondScore,
          'deviceSpace': useDeviceSpace,
        },
      );

      BiometriaMatchFromImageResult? serverResult;
      if (!skipServer) {
        if (_requiresServerMatch && mounted) {
          setState(() {
            _uiByTrack[trackId] = _FaceUi(
              color: const Color(0xFFF9A825),
              label: 'Validando identidad en servidor...',
            );
          });
        }
        try {
          final jpegBytes = encodeBiometricJpegForServer(rgbCrop);
          serverResult = await OfflineBootstrap.empleadosRemote
              .matchBiometriaFromImage(base64Encode(jpegBytes));
        } catch (e, st) {
          AppLogger.instance.d(
            'match-from-image excepcion no controlada',
            error: e,
            stackTrace: st,
          );
          serverResult = BiometriaMatchFromImageResult.fromNetworkException(
            NetworkException(e.toString()),
          );
        }
      } else {
        AppLogger.instance.d(
          'match-from-image omitido: resultado local suficientemente estable',
        );
        serverResult = null;
      }

      if (serverResult != null && serverResult.isSuccess) {
        final payload = serverResult.payload!;
        final empUuid = payload['empleadoId']?.toString() ??
            payload['empleado_id']?.toString() ??
            '';
        if (empUuid.isNotEmpty) {
          final empIdHash = stableLocalIdFromRemote(empUuid);
          var name = payload['nombreCompleto']?.toString().trim() ?? '';
          if (name.isEmpty) {
            for (final c in _catalog) {
              if (c.empleadoId == empIdHash) {
                name = c.displayName;
                break;
              }
            }
            if (name.isEmpty) name = 'Empleado';
          }
          final score = (payload['score'] as num?)?.toDouble() ?? 0;
          match = LocalFaceMatch(
            candidate: LocalFaceCandidate(
              empleadoId: empIdHash,
              displayName: name,
              embedding: const [],
            ),
            score: score,
          );
          matchFromServer = true;
          _inferenceMs = 0;
          PerformanceMonitor.instance.start('embedding_compare');
          _comparisonMs = PerformanceMonitor.instance.stop(
            'embedding_compare',
            extra: {'source': 'server_insightface'},
          );
        } else {
          _resetRecognitionStateForTrack(trackId);
          if (!mounted) return;
          setState(() {
            _uiByTrack[trackId] = _FaceUi(
              color: const Color(0xFFFF9800),
              label: 'Servidor: respuesta incompleta (sin empleado)',
            );
          });
          return;
        }
      } else if (serverResult != null && !serverResult.allowLocalFallback) {
        final rejected = serverResult;
        final outcome = rejected.outcome;
        final label = _labelForServerMatchRejection(rejected);
        _resetRecognitionStateForTrack(trackId);
        if (!mounted) return;
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: _colorForServerMatchRejection(outcome),
            label: label,
          );
        });
        return;
      } else {
        if (serverResult != null) {
          AppLogger.instance.d(
            'match-from-image: se usara comparacion local (${serverResult.message ?? "sin detalle"})',
          );
        }
        if (_catalogDevice.isEmpty) {
          if (!mounted) return;
          setState(() {
            _uiByTrack[trackId] = _FaceUi(
              color: const Color(0xFFFF9800),
              label: 'Sin plantilla offline. Sincronice biometría.',
            );
          });
          return;
        }
        final sep = top.bestScore - top.secondScore;
        ambiguous = multi && top.secondScore > -1 && sep < _deviceMinMargin;
        final scoreOk =
            top.bestScore >= _deviceMinCosine && (!multi || sep >= _deviceMinMargin);
        if (top.best != null && scoreOk && !ambiguous) {
          match = LocalFaceMatch(candidate: top.best!, score: top.bestScore);
          matchFromDevice = true;
        }
      }

      if (!mounted) return;

      if (match == null) {
        _resetRecognitionStateForTrack(trackId);
        final sep = top.bestScore - top.secondScore;
        final dbg = kDebugMode
            ? ' · cos ${top.bestScore.toStringAsFixed(2)}'
                '${multi ? ' Δ${sep.toStringAsFixed(2)}' : ''}'
            : '';
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: const Color(0xFFE53935),
            label: ambiguous
                ? 'Desconocido (muy parecido a otro)$dbg'
                : 'Desconocido$dbg',
          );
        });
        return;
      }

      final empId = match.candidate.empleadoId;
      final name = match.candidate.displayName;
      final scoreStr = match.score.toStringAsFixed(2);
      final sepLocal = top.bestScore - top.secondScore;
      final canShowName = matchFromServer ||
          (matchFromDevice &&
              match.score >= _deviceMinCosineToShowName &&
              (!multi || sepLocal >= _deviceMinMargin));
      if (!canShowName) {
        if (!mounted) return;
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: const Color(0xFFE53935),
            label: 'Desconocido',
          );
        });
        return;
      }
      final canMark = matchFromServer ||
          (matchFromDevice && match.score >= _deviceMinCosineToMark);
      if (!canMark) {
        if (!mounted) return;
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: const Color(0xFFF9A825),
            label: '$name · sim $scoreStr',
          );
        });
        return;
      }
      final stableIdentity = _isStableIdentity(
        trackId,
        empId,
        minFrames: matchFromServer
            ? _serverStableFrames(match.score)
            : (matchFromDevice ? 3 : _requiredStableFrames(match.score)),
      );
      if (!stableIdentity) {
        if (!mounted) return;
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: const Color(0xFFF9A825),
            label: 'Verificando identidad...',
          );
        });
        return;
      }

      if (_inCooldown(empId, now)) {
        final until = _cooldownUntil[empId];
        final greenUntil = _successGreenUntil[empId];
        final inGreenFlash = greenUntil != null &&
            now.isBefore(greenUntil) &&
            until != null &&
            now.isBefore(until);
        if (inGreenFlash) {
          setState(() {
            _uiByTrack[trackId] = _FaceUi(
              color: const Color(0xFF2E7D32),
              label: '$name · Marcación registrada · sim $scoreStr',
            );
          });
        } else {
          final remaining = until != null
              ? _formatCooldownRemaining(until, now)
              : '${_marcacionCooldownSeconds}s';
          setState(() {
            _uiByTrack[trackId] = _FaceUi(
              color: const Color(0xFFF9A825),
              label:
                  '$name · Ya registrado · anti-duplicado 5 min · próxima en $remaining',
            );
          });
        }
        return;
      }

      try {
        PerformanceMonitor.instance.start('marcacion_local_sync');
        await OfflineBootstrap.marcacionService.registrarMarcacion(
          empId,
          'entrada',
          metodo: 'facial',
        );
        _syncMs = PerformanceMonitor.instance.stop('marcacion_local_sync');
        _setCooldown(empId, _marcacionCooldownSeconds);
        _successGreenUntil[empId] = DateTime.now()
            .add(const Duration(seconds: _successGreenFlashSeconds));
        if (!mounted) return;
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: const Color(0xFF2E7D32),
            label: matchFromServer
                ? '$name · Marcación registrada · sim $scoreStr'
                : '$name · Marcación offline (pend. servidor) · sim $scoreStr',
          );
        });
      } catch (e, st) {
        AppLogger.instance
            .e('Error registrando marcacion offline', error: e, stackTrace: st);
        _handleMarkError(trackId, name, scoreStr);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uiByTrack[trackId] = _FaceUi(
            color: const Color(0xFFF9A825),
            label: 'Error reconocimiento: $e',
          );
        });
      }
    }
  }

  void _handleMarkError(int trackId, String name, String scoreStr) {
    if (!mounted) return;
    setState(() {
      _uiByTrack[trackId] = _FaceUi(
        color: const Color(0xFFF9A825),
        label: '$name · Error de marcacion · sim $scoreStr',
      );
    });
  }

  void _countFps() {
    _frameCounter++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsTick).inMilliseconds;
    if (elapsed < 1000) return;
    _fps = (_frameCounter * 1000) / elapsed;
    if (_fps < 12 && _frameSkip < 4) {
      _frameSkip++;
    } else if (_fps > 20 && _frameSkip > 1) {
      _frameSkip--;
    }
    _frameCounter = 0;
    _lastFpsTick = now;
  }

  @override
  void dispose() {
    _networkModeSub?.cancel();
    final c = _camera;
    _camera = null;
    if (c != null) {
      if (c.value.isStreamingImages) {
        c.stopImageStream().catchError((_) {}).then((_) => c.dispose());
      } else {
        c.dispose();
      }
    }
    _detector.dispose();
    _embeddingService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcacion facial'),
        actions: [
          if (!widget.session.isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: ConnectivityStatusBadge(compact: true),
            ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: _switchCamera,
            tooltip: 'Cambiar cámara',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _catalogLoading
                ? null
                : () async {
                    _catalogService.invalidateCache();
                    await _syncAndReloadCatalog();
                  },
            tooltip: 'Recargar catalogo',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              try {
                final cam = _camera;
                if (cam != null && cam.value.isStreamingImages) {
                  await cam.stopImageStream();
                }
              } catch (_) {}
              await widget.onLogout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_degradedOfflineMode)
            MaterialBanner(
              content: const Text(
                'Sin conexión al servidor: modo local temporal. '
                'Las marcas se encolan y se validan al recuperar la red.',
              ),
              leading: const Icon(Icons.cloud_off_rounded),
              backgroundColor: Colors.orange.shade50,
              actions: const [SizedBox.shrink()],
            ),
          if (widget.session.isOffline)
            const MaterialBanner(
              content: Text(
                'Sesión sin conexión (PIN). Solo comparación local; sincronice al volver en línea.',
              ),
              leading: Icon(Icons.offline_bolt_rounded),
              actions: [SizedBox.shrink()],
            ),
          if (_loadError != null)
            MaterialBanner(
              content: Text(_loadError!),
              actions: [
                TextButton(
                  onPressed: _catalogLoading ? null : _retryAll,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          if (_catalogLoading) const LinearProgressIndicator(minHeight: 3),
          if (!_catalogLoading &&
              _catalogDevice.isEmpty &&
              _catalog.isEmpty &&
              _loadError == null)
            MaterialBanner(
              content: const Text(
                'No hay empleados con biometria activa. Sincroniza y/o registra rostros en el panel web.',
              ),
              actions: [
                TextButton(
                    onPressed: _syncAndReloadCatalog,
                    child: const Text('Actualizar')),
              ],
            ),
          Expanded(
            child: _camera == null || !_camera!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return ColoredBox(
                        color: Colors.black,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: 1 / _camera!.value.aspectRatio,
                                child: CameraPreview(_camera!),
                              ),
                            ),
                            CustomPaint(
                              size: Size(
                                  constraints.maxWidth, constraints.maxHeight),
                              painter: _FaceOverlayPainter(
                                faces: _faces,
                                imageSize: _imageSize,
                                uiByTrack: _uiByTrack,
                                lensDirection:
                                    _camera!.description.lensDirection,
                                canvasSize: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _legend(const Color(0xFF2E7D32),
                          'Marcación registrada (éxito)'),
                      _legend(
                        const Color(0xFFF9A825),
                        'Conocido: espera 5 min entre marcas o verificando',
                      ),
                      _legend(const Color(0xFFE53935), 'Desconocido'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Offline: ${_catalogDevice.length} · InsightFace: ${_catalog.length} · FPS: ${_fps.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Infer: ${_inferenceMs}ms · Comp: ${_comparisonMs}ms · Sync: ${_syncMs}ms',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _requiresServerMatch
                        ? 'Modo en línea: identidad validada en servidor (InsightFace).'
                        : _degradedOfflineMode
                            ? 'Modo local temporal: sin API; comparación TFLite hasta recuperar red.'
                            : widget.session.isOffline
                                ? 'Modo offline (PIN): comparación local TFLite.'
                                : 'Inicializando modo de red…',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _detectStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: _detectStatus.contains('Error')
                          ? Colors.orange.shade800
                          : Colors.blueGrey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _FaceOverlayPainter extends CustomPainter {
  _FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.uiByTrack,
    required this.lensDirection,
    required this.canvasSize,
  });

  final List<Face> faces;
  final Size imageSize;
  final Map<int, _FaceUi> uiByTrack;
  final CameraLensDirection lensDirection;
  final Size canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return;

    final w = canvasSize.width;
    final h = canvasSize.height;
    final imgW = imageSize.width;
    final imgH = imageSize.height;

    final scale = (w / imgW < h / imgH) ? w / imgW : h / imgH;
    final videoW = imgW * scale;
    final videoH = imgH * scale;
    final offX = (w - videoW) / 2;
    final offY = (h - videoH) / 2;

    for (final face in faces) {
      final tid = face.trackingId ??
          Object.hash(
            face.boundingBox.left.round(),
            face.boundingBox.top.round(),
          );
      final ui = uiByTrack[tid] ??
          _FaceUi(
            color: const Color(0xFF78909C).withValues(alpha: 0.92),
            label: 'Analizando...',
          );

      final b = expandFaceRectForEmbedding(
        face.boundingBox,
        imgW.round(),
        imgH.round(),
        horizontalCenterShiftFactor: lensDirection == CameraLensDirection.front
            ? _FaceAttendanceScreenState._frontLensHorizontalCenterShiftFactor
            : 0.0,
      );
      var left = b.left * scale + offX;
      var top = b.top * scale + offY;
      var right = b.right * scale + offX;
      var bottom = b.bottom * scale + offY;

      if (lensDirection == CameraLensDirection.front) {
        final c = offX + videoW / 2;
        final nl = 2 * c - right;
        final nr = 2 * c - left;
        left = nl;
        right = nr;
        if (left > right) {
          final t = left;
          left = right;
          right = t;
        }
      }

      final rect = Rect.fromLTRB(left, top, right, bottom);
      final paint = Paint()
        ..color = ui.color.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(RRect.fromRectXY(rect, 8, 8), paint);

      final tp = TextPainter(
        text: TextSpan(
          text: ui.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: math.max(80.0, w - 16));

      final maxLeft = math.max(4.0, w - tp.width - 4);
      final labelY = (top - tp.height - 6).clamp(4.0, h - tp.height - 4);
      tp.paint(canvas, Offset(left.clamp(4, maxLeft), labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.uiByTrack != uiByTrack ||
        oldDelegate.canvasSize != canvasSize;
  }
}
