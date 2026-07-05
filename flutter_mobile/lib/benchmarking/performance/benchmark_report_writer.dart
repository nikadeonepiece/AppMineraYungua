import 'dart:convert';
import 'dart:io';

import 'benchmark_models.dart';

class BenchmarkReportWriter {
  static const _warnDegradationPercent = 35.0;
  static const _criticalRamMb = 900.0;
  static const _criticalFps = 12.0;
  static const _warnRecognitionLatencyMs = 120.0;

  Future<BenchmarkWriteResult> writeAll(BenchmarkReport report) async {
    final targetDir = Directory('benchmark/results');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final degradation = _buildDegradation(report.results);
    final alerts = _buildAlerts(report.results, degradation);

    final payload = {
      'created_at': report.createdAtIso,
      'device': report.deviceInfo,
      'results': report.results.map(_scenarioToJson).toList(growable: false),
      'degradation_percent': degradation,
      'alerts': alerts,
      'thresholds': {
        'warning_degradation_percent': _warnDegradationPercent,
        'critical_ram_mb': _criticalRamMb,
        'critical_fps': _criticalFps,
        'warning_recognition_latency_ms': _warnRecognitionLatencyMs,
      },
    };

    final jsonFile = File('${targetDir.path}/benchmark_results.json');
    await jsonFile.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));

    final mdFile = File('${targetDir.path}/benchmark_report.md');
    await mdFile.writeAsString(_buildMarkdown(report, degradation, alerts));

    return BenchmarkWriteResult(
      jsonPath: jsonFile.path,
      markdownPath: mdFile.path,
    );
  }

  Map<String, Object?> _scenarioToJson(BenchmarkScenarioResult r) {
    return {
      'scenario': {
        'name': r.scenario.name,
        'total_embeddings': r.scenario.totalEmbeddings,
        'embeddings_per_employee': r.scenario.embeddingsPerEmployee,
      },
      'comparison_ms': _metricToJson(r.comparisonMs),
      'inference_ms': _metricToJson(r.inferenceMs),
      'fps': _metricToJson(r.fps),
      'sync_ms': _metricToJson(r.syncMs),
      'sync_throughput_items_per_sec': r.syncThroughputItemsPerSec,
      'ram_before_mb': r.ramBeforeMb,
      'ram_after_mb': r.ramAfterMb,
      'cpu_usage_proxy': r.cpuUsageProxy,
      'gpu_usage_proxy': r.gpuUsageProxy,
      'isar_size_mb': r.isarSizeMb,
      'battery_drop_percent': r.batteryDropPercent,
      'battery_drain_per_hour_percent': r.batteryDrainPerHourPercent,
    };
  }

  Map<String, Map<String, double>> _buildDegradation(List<BenchmarkScenarioResult> results) {
    if (results.isEmpty) return const {};
    final baseline = results.first;
    final out = <String, Map<String, double>>{};

    for (final r in results) {
      out[r.scenario.name] = {
        'comparison_avg_ms': _pct(baseline.comparisonMs.avg, r.comparisonMs.avg),
        'inference_avg_ms': _pct(baseline.inferenceMs.avg, r.inferenceMs.avg),
        'fps_avg': _pctPositiveIsBetter(baseline.fps.avg, r.fps.avg),
        'ram_after_mb': _pct(baseline.ramAfterMb, r.ramAfterMb),
        'isar_size_mb': _pct(baseline.isarSizeMb, r.isarSizeMb),
        'sync_ms_avg': _pct(baseline.syncMs.avg, r.syncMs.avg),
        'sync_throughput': _pctPositiveIsBetter(
          baseline.syncThroughputItemsPerSec,
          r.syncThroughputItemsPerSec,
        ),
      };
    }
    return out;
  }

  List<String> _buildAlerts(
    List<BenchmarkScenarioResult> results,
    Map<String, Map<String, double>> degradation,
  ) {
    final alerts = <String>[];
    for (final r in results) {
      final name = r.scenario.name;
      final d = degradation[name] ?? const {};
      final worstDeg = d.values.fold<double>(0.0, (a, b) => b > a ? b : a);
      if (worstDeg > _warnDegradationPercent) {
        alerts.add('WARNING: degradacion alta en $name (${worstDeg.toStringAsFixed(1)}%)');
      }
      if (r.ramAfterMb > _criticalRamMb) {
        alerts.add('CRITICAL: RAM en $name = ${r.ramAfterMb.toStringAsFixed(1)} MB');
      }
      if (r.fps.avg < _criticalFps) {
        alerts.add('CRITICAL: FPS bajo en $name = ${r.fps.avg.toStringAsFixed(1)}');
      }
      if (r.comparisonMs.avg > _warnRecognitionLatencyMs) {
        alerts.add(
          'WARNING: latencia reconocimiento alta en $name = ${r.comparisonMs.avg.toStringAsFixed(1)} ms',
        );
      }
    }
    if (alerts.isEmpty) {
      alerts.add('OK: no se detectaron alertas criticas con los umbrales actuales.');
    }
    return alerts;
  }

  String _buildMarkdown(
    BenchmarkReport report,
    Map<String, Map<String, double>> degradation,
    List<String> alerts,
  ) {
    final b = StringBuffer();
    b.writeln('# Benchmark Ejecutivo - Sistema Biometrico Offline');
    b.writeln();
    b.writeln('- Fecha: `${report.createdAtIso}`');
    b.writeln('- Dispositivo: `${report.deviceInfo}`');
    b.writeln();
    b.writeln('## Tabla Comparativa');
    b.writeln();
    b.writeln(
      '| Escenario | Comp avg (ms) | Comp max (ms) | p95 (ms) | Infer avg (ms) | FPS avg | RAM after (MB) | CPU proxy | Isar (MB) | Sync throughput (it/s) |',
    );
    b.writeln('|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|');
    for (final r in report.results) {
      b.writeln(
        '| ${r.scenario.name} | ${r.comparisonMs.avg.toStringAsFixed(2)} | ${r.comparisonMs.max.toStringAsFixed(2)} | ${r.comparisonMs.p95.toStringAsFixed(2)} | ${r.inferenceMs.avg.toStringAsFixed(2)} | ${r.fps.avg.toStringAsFixed(2)} | ${r.ramAfterMb.toStringAsFixed(1)} | ${r.cpuUsageProxy.toStringAsFixed(2)} | ${r.isarSizeMb.toStringAsFixed(2)} | ${r.syncThroughputItemsPerSec.toStringAsFixed(2)} |',
      );
    }
    b.writeln();
    b.writeln('## Degradacion Progresiva (baseline: 1k)');
    b.writeln();
    b.writeln('| Escenario | Comp avg % | Infer avg % | FPS % | RAM % | Isar % | Sync % | Throughput % |');
    b.writeln('|---|---:|---:|---:|---:|---:|---:|---:|');
    for (final r in report.results) {
      final d = degradation[r.scenario.name] ?? const {};
      b.writeln(
        '| ${r.scenario.name} | ${_fmt(d['comparison_avg_ms'])} | ${_fmt(d['inference_avg_ms'])} | ${_fmt(d['fps_avg'])} | ${_fmt(d['ram_after_mb'])} | ${_fmt(d['isar_size_mb'])} | ${_fmt(d['sync_ms_avg'])} | ${_fmt(d['sync_throughput'])} |',
      );
    }
    b.writeln();
    b.writeln('## Alertas Automaticas');
    b.writeln();
    for (final a in alerts) {
      b.writeln('- $a');
    }
    b.writeln();
    b.writeln('## Conclusiones Automaticas');
    b.writeln();
    final capacity = _estimateCapacity(report.results);
    b.writeln('- Capacidad estimada del dispositivo: **$capacity**');
    b.writeln('- Limite operativo sugerido: **${_suggestedLimit(report.results)}**');
    b.writeln('- Riesgo principal: **${_biggestRisk(report.results, alerts)}**');
    b.writeln();
    b.writeln('## Recomendaciones Performance');
    b.writeln();
    b.writeln('- Mantener `frameSkip` adaptativo y monitorizar p95 de comparacion.');
    b.writeln('- Si RAM supera umbral, bajar embeddings activos en cache o aplicar cuantizacion adicional.');
    b.writeln('- Si FPS cae < $_criticalFps, bajar resolucion de camara y batch de comparacion.');
    b.writeln('- Revisar throughput de sync al crecer colas para ajustar tamano de lote.');
    return b.toString();
  }

  String _fmt(double? value) => value == null ? '-' : value.toStringAsFixed(1);

  double _pct(double base, double current) {
    if (base == 0) return 0;
    return ((current - base) / base) * 100;
  }

  double _pctPositiveIsBetter(double base, double current) {
    if (base == 0) return 0;
    return ((base - current) / base) * 100;
  }

  String _estimateCapacity(List<BenchmarkScenarioResult> results) {
    if (results.isEmpty) return 'no disponible';
    final worst = results.last;
    if (worst.fps.avg >= 20 && worst.ramAfterMb < _criticalRamMb) {
      return 'ALTA (10k embeddings operables)';
    }
    if (worst.fps.avg >= 14) {
      return 'MEDIA (5k a 10k segun carga de sync)';
    }
    return 'LIMITADA (recomendado <=5k embeddings simultaneos)';
  }

  String _suggestedLimit(List<BenchmarkScenarioResult> results) {
    if (results.isEmpty) return 'sin datos';
    final tenK = results.where((e) => e.scenario.name == '10k').firstOrNull;
    if (tenK != null && tenK.fps.avg >= _criticalFps && tenK.ramAfterMb < _criticalRamMb) {
      return '10k embeddings';
    }
    final fiveK = results.where((e) => e.scenario.name == '5k').firstOrNull;
    if (fiveK != null) return '5k embeddings';
    return '1k embeddings';
  }

  String _biggestRisk(List<BenchmarkScenarioResult> results, List<String> alerts) {
    if (alerts.any((a) => a.startsWith('CRITICAL: RAM'))) return 'consumo de memoria';
    if (alerts.any((a) => a.startsWith('CRITICAL: FPS'))) return 'caida de FPS en tiempo real';
    if (alerts.any((a) => a.contains('latencia reconocimiento'))) return 'latencia de reconocimiento';
    if (results.isEmpty) return 'sin datos';
    return 'degradacion progresiva bajo alta carga';
  }

  Map<String, Object?> _metricToJson(MetricSummary m) {
    return {
      'avg': m.avg,
      'max': m.max,
      'p50': m.p50,
      'p95': m.p95,
      'p99': m.p99,
    };
  }
}

class BenchmarkWriteResult {
  const BenchmarkWriteResult({
    required this.jsonPath,
    required this.markdownPath,
  });

  final String jsonPath;
  final String markdownPath;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
