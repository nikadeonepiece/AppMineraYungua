import 'dart:math' as math;

import 'benchmark_models.dart';

class BenchmarkStats {
  static MetricSummary from(List<double> values) {
    if (values.isEmpty) {
      return const MetricSummary(avg: 0, max: 0, p50: 0, p95: 0, p99: 0);
    }
    final sorted = [...values]..sort();
    final sum = values.fold<double>(0, (a, b) => a + b);
    return MetricSummary(
      avg: sum / values.length,
      max: sorted.last,
      p50: _percentile(sorted, 0.50),
      p95: _percentile(sorted, 0.95),
      p99: _percentile(sorted, 0.99),
    );
  }

  static double _percentile(List<double> sorted, double p) {
    if (sorted.isEmpty) return 0;
    final idx = math.max(0, math.min(sorted.length - 1, (sorted.length * p).floor()));
    return sorted[idx];
  }
}
