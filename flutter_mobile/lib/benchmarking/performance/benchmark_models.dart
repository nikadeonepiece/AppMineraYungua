class BenchmarkScenario {
  const BenchmarkScenario({
    required this.name,
    required this.totalEmbeddings,
    required this.embeddingsPerEmployee,
  });

  final String name;
  final int totalEmbeddings;
  final int embeddingsPerEmployee;

  int get employeeCount {
    final value = totalEmbeddings ~/ embeddingsPerEmployee;
    return value <= 0 ? 1 : value;
  }
}

class MetricSummary {
  const MetricSummary({
    required this.avg,
    required this.max,
    required this.p50,
    required this.p95,
    required this.p99,
  });

  final double avg;
  final double max;
  final double p50;
  final double p95;
  final double p99;
}

class BenchmarkScenarioResult {
  const BenchmarkScenarioResult({
    required this.scenario,
    required this.comparisonMs,
    required this.inferenceMs,
    required this.fps,
    required this.syncMs,
    required this.syncThroughputItemsPerSec,
    required this.ramBeforeMb,
    required this.ramAfterMb,
    required this.cpuUsageProxy,
    required this.gpuUsageProxy,
    required this.isarSizeMb,
    required this.batteryDropPercent,
    required this.batteryDrainPerHourPercent,
  });

  final BenchmarkScenario scenario;
  final MetricSummary comparisonMs;
  final MetricSummary inferenceMs;
  final MetricSummary fps;
  final MetricSummary syncMs;
  final double syncThroughputItemsPerSec;
  final double ramBeforeMb;
  final double ramAfterMb;
  final double cpuUsageProxy;
  final double gpuUsageProxy;
  final double isarSizeMb;
  final double batteryDropPercent;
  final double batteryDrainPerHourPercent;
}

class BenchmarkReport {
  const BenchmarkReport({
    required this.createdAtIso,
    required this.deviceInfo,
    required this.results,
  });

  final String createdAtIso;
  final Map<String, Object?> deviceInfo;
  final List<BenchmarkScenarioResult> results;
}
