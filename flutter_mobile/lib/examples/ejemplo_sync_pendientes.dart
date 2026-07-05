import '../core/bootstrap/offline_bootstrap.dart';
import '../core/database/database_service.dart';

Future<void> runSyncPendientesExample() async {
  await DatabaseService.instance.initialize();
  await OfflineBootstrap.syncManager.uploadMarcaciones();
}
