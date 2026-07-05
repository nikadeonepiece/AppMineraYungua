import 'package:workmanager/workmanager.dart';

import '../core/utils/app_logger.dart';
import '../data/sync/sync_manager.dart';
import 'offline_sync_entry.dart';

class SyncWorker {
  SyncWorker._();

  static const taskName = 'offline_sync_task';
  static const _periodicUniqueName = 'control_asistencia_periodic_sync';

  static var _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Workmanager().initialize(
      offlineSyncCallbackDispatcher,
    );
    _initialized = true;
  }

  /// Tarea periodica cuando hay sesion online (Android: min ~15 min). Idempotente.
  static Future<void> registerPeriodicSync() async {
    try {
      await initialize();
      await Workmanager().registerPeriodicTask(
        _periodicUniqueName,
        taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      AppLogger.instance.i('Workmanager: tarea periodica de sync registrada');
    } catch (e, st) {
      AppLogger.instance.w(
        'Workmanager: no se pudo registrar tarea periodica ($e)',
        stackTrace: st,
      );
    }
  }

  static Future<void> cancelPeriodicSync() async {
    try {
      await initialize();
      await Workmanager().cancelByUniqueName(_periodicUniqueName);
      AppLogger.instance.i('Workmanager: tarea periodica de sync cancelada');
    } catch (e, st) {
      AppLogger.instance.w('Workmanager: cancelacion omitida ($e)', stackTrace: st);
    }
  }

  static Future<void> executeSync(SyncManager syncManager) async {
    AppLogger.instance.i('SyncWorker ejecutando sincronizacion manual');
    await syncManager.syncAll();
  }
}
