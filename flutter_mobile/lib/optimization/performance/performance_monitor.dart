import '../../core/utils/app_logger.dart';

class PerformanceMonitor {
  PerformanceMonitor._();
  static final PerformanceMonitor instance = PerformanceMonitor._();

  final Map<String, Stopwatch> _active = {};

  void start(String key) {
    _active[key] = Stopwatch()..start();
  }

  int stop(String key, {Map<String, Object?> extra = const {}}) {
    final sw = _active.remove(key);
    if (sw == null) return 0;
    sw.stop();
    final elapsed = sw.elapsedMilliseconds;
    AppLogger.instance.i('[PERF][$key] ${elapsed}ms $extra');
    return elapsed;
  }
}
