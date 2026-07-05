import '../core/bootstrap/offline_bootstrap.dart';
import '../core/database/database_service.dart';

Future<void> runSyncEmpleadosExample() async {
  await DatabaseService.instance.initialize();
  await OfflineBootstrap.syncManager.syncEmpleados();
}
