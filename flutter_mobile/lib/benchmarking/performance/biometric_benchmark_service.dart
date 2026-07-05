import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../biometric/embeddings/face_embedding_service.dart';
import '../../biometric/matching/local_face_matcher.dart';
import '../../core/bootstrap/offline_bootstrap.dart';
import '../../core/utils/app_logger.dart';
import 'benchmark_models.dart';
import 'benchmark_stats.dart';
import 'resource_sampler.dart';
import 'synthetic_embedding_generator.dart';

class BiometricBenchmarkService {
  BiometricBenchmarkService({
    SyntheticEmbeddingGenerator? generator,
    ResourceSampler? sampler,
  })  : _generator = generator ?? SyntheticEmbeddingGenerator(seed: 2026),
        _sampler = sampler ?? ResourceSampler();

  final SyntheticEmbeddingGenerator _generator;
  final ResourceSampler _sampler;
  final LocalFaceMatcher _matcher = LocalFaceMatcher(threshold: 0.75);

  Future<BenchmarkReport> run({
    required List<BenchmarkScenario> scenarios,
    int iterations = 120,
  }) async {
    final results = <BenchmarkScenarioResult>[];
    final batteryStart = await _sampler.batteryLevel();
    final start = DateTime.now();

    for (final scenario in scenarios) {
      AppLogger.instance.i('[BENCH] Iniciando escenario ${scenario.name}');
      final ramBefore = _sampler.currentRssMb();
      final dataset = _generator.generate(
        totalEmbeddings: scenario.totalEmbeddings,
        employeeCount: scenario.employeeCount,
        embeddingsPerEmployee: scenario.embeddingsPerEmployee,
      );

      final comparisonTimes = <double>[];
      final fpsSamples = <double>[];
      final swFps = Stopwatch()..start();
      var frameCount = 0;
      for (var i = 0; i < iterations; i++) {
        final query = _generator.queryFromEmployee(dataset, (i % scenario.employeeCount) + 1);
        final sw = Stopwatch()..start();
        await _matcher.findBestMatchIsolated(query, dataset);
        sw.stop();
        comparisonTimes.add(sw.elapsedMicroseconds / 1000.0);
        frameCount++;
        if (swFps.elapsedMilliseconds >= 1000) {
          fpsSamples.add(frameCount * 1000 / swFps.elapsedMilliseconds);
          frameCount = 0;
          swFps
            ..stop()
            ..reset()
            ..start();
        }
      }
      swFps.stop();

      final inferenceTimes = await _runInferenceBench(iterations: math.min(50, iterations));
      final syncResult = await _runSyncBench(iterations: math.min(30, iterations));

      final ramAfter = _sampler.currentRssMb();
      final isarSize = await _isarStorageSizeMb();

      final cpuProxy = _cpuProxy(comparisonTimes: comparisonTimes, inferenceTimes: inferenceTimes);
      final gpuProxy = _gpuProxy(fpsSamples: fpsSamples, inferenceTimes: inferenceTimes);

      final batteryNow = await _sampler.batteryLevel();
      final elapsedHours = math.max(
        1e-6,
        DateTime.now().difference(start).inMilliseconds / 3600000.0,
      );
      final batteryDrop = (batteryStart >= 0 && batteryNow >= 0)
          ? ((batteryStart - batteryNow).toDouble().clamp(0, 100) as double)
          : 0.0;
      final drainPerHour = batteryDrop / elapsedHours;

      results.add(
        BenchmarkScenarioResult(
          scenario: scenario,
          comparisonMs: BenchmarkStats.from(comparisonTimes),
          inferenceMs: BenchmarkStats.from(inferenceTimes),
          fps: BenchmarkStats.from(fpsSamples.isEmpty ? [0] : fpsSamples),
          syncMs: BenchmarkStats.from(syncResult.timesMs),
          syncThroughputItemsPerSec: syncResult.throughputItemsPerSec,
          ramBeforeMb: ramBefore,
          ramAfterMb: ramAfter,
          cpuUsageProxy: cpuProxy,
          gpuUsageProxy: gpuProxy,
          isarSizeMb: isarSize,
          batteryDropPercent: batteryDrop,
          batteryDrainPerHourPercent: drainPerHour,
        ),
      );
    }

    return BenchmarkReport(
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      deviceInfo: {
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      },
      results: results,
    );
  }

  Future<List<double>> _runInferenceBench({required int iterations}) async {
    final times = <double>[];
    try {
      final service = await FaceEmbeddingService.create();
      final image = _syntheticFaceCrop();
      for (var i = 0; i < iterations; i++) {
        final sw = Stopwatch()..start();
        service.generateEmbedding(image);
        sw.stop();
        times.add(sw.elapsedMicroseconds / 1000.0);
      }
      service.dispose();
    } catch (e) {
      AppLogger.instance.w('[BENCH] Inference benchmark omitido: $e');
      if (times.isEmpty) times.add(0);
    }
    return times;
  }

  Future<_SyncBenchResult> _runSyncBench({required int iterations}) async {
    final times = <double>[];
    var totalItems = 0;
    for (var i = 0; i < iterations; i++) {
      final sw = Stopwatch()..start();
      await OfflineBootstrap.syncManager.uploadMarcaciones();
      sw.stop();
      times.add(sw.elapsedMicroseconds / 1000.0);
      totalItems += 1;
    }
    final totalMs = times.fold<double>(0, (a, b) => a + b);
    final throughput = totalMs <= 0 ? 0.0 : (totalItems * 1000.0) / totalMs;
    return _SyncBenchResult(timesMs: times, throughputItemsPerSec: throughput);
  }

  img.Image _syntheticFaceCrop() {
    final image = img.Image(width: 112, height: 112);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final cx = x - image.width / 2;
        final cy = y - image.height / 2;
        final r = math.sqrt(cx * cx + cy * cy);
        final shade = (220 - (r * 2)).clamp(60, 235).toInt();
        image.setPixelRgb(x, y, shade, shade - 8, shade - 16);
      }
    }
    return image;
  }

  double _cpuProxy({
    required List<double> comparisonTimes,
    required List<double> inferenceTimes,
  }) {
    final avgCompare = comparisonTimes.isEmpty
        ? 0
        : comparisonTimes.reduce((a, b) => a + b) / comparisonTimes.length;
    final avgInfer =
        inferenceTimes.isEmpty ? 0 : inferenceTimes.reduce((a, b) => a + b) / inferenceTimes.length;
    return ((avgCompare + avgInfer) / 33.0).clamp(0.0, 1.0);
  }

  double _gpuProxy({
    required List<double> fpsSamples,
    required List<double> inferenceTimes,
  }) {
    final avgFps = fpsSamples.isEmpty ? 0.0 : fpsSamples.reduce((a, b) => a + b) / fpsSamples.length;
    final fpsBudget = avgFps <= 0 ? 1.0 : (60.0 / avgFps);
    final avgInfer =
        inferenceTimes.isEmpty ? 0.0 : inferenceTimes.reduce((a, b) => a + b) / inferenceTimes.length;
    return (avgInfer / (fpsBudget * 10)).clamp(0.0, 1.0);
  }

  Future<double> _isarStorageSizeMb() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(docs.path);
    if (!await dir.exists()) return 0;
    var bytes = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (!entity.path.contains('control_asistencia')) continue;
      bytes += await entity.length();
    }
    return bytes / (1024 * 1024);
  }
}

class _SyncBenchResult {
  const _SyncBenchResult({
    required this.timesMs,
    required this.throughputItemsPerSec,
  });

  final List<double> timesMs;
  final double throughputItemsPerSec;
}
