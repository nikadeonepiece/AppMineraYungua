import '../benchmarking/performance/benchmark_models.dart';
import '../benchmarking/performance/benchmark_report_writer.dart';
import '../benchmarking/performance/biometric_benchmark_service.dart';
import '../core/bootstrap/offline_bootstrap.dart';
import '../core/database/database_service.dart';
import '../core/utils/app_logger.dart';
import '../security/security_bootstrap.dart';

Future<void> runOfflineBiometricBenchmark() async {
  await SecurityBootstrap.initialize();
  await DatabaseService.instance.initialize();
  await OfflineBootstrap.runLocalSecurityMigrations();

  final service = BiometricBenchmarkService();
  final report = await service.run(
    scenarios: const [
      BenchmarkScenario(name: '1k', totalEmbeddings: 1000, embeddingsPerEmployee: 3),
      BenchmarkScenario(name: '5k', totalEmbeddings: 5000, embeddingsPerEmployee: 3),
      BenchmarkScenario(name: '10k', totalEmbeddings: 10000, embeddingsPerEmployee: 3),
    ],
    iterations: 150,
  );

  final writer = BenchmarkReportWriter();
  final output = await writer.writeAll(report);
  AppLogger.instance.i('Benchmark completado. JSON: ${output.jsonPath}');
  AppLogger.instance.i('Benchmark completado. Markdown: ${output.markdownPath}');
}
