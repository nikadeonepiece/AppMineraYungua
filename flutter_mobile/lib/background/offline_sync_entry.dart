import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../core/bootstrap/offline_bootstrap.dart';
import '../core/database/database_service.dart';
import '../core/utils/app_logger.dart';
import 'sync_worker.dart';

/// Punto de entrada aislado para Workmanager (no usar closures de la app principal).
@pragma('vm:entry-point')
void offlineSyncCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != SyncWorker.taskName) {
      return Future.value(false);
    }
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await DatabaseService.instance.initialize();
      await OfflineBootstrap.runLocalSecurityMigrations();
      await OfflineBootstrap.syncManager.syncAll();
      AppLogger.instance.i('Workmanager: syncAll completado');
      return Future.value(true);
    } catch (e, st) {
      AppLogger.instance.e(
        'Workmanager: error en sync offline',
        error: e,
        stackTrace: st,
      );
      return Future.value(false);
    }
  });
}
