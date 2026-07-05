import '../core/bootstrap/offline_bootstrap.dart';
import '../core/database/database_service.dart';

Future<void> runMarcacionOfflineExample() async {
  await DatabaseService.instance.initialize();
  await OfflineBootstrap.marcacionService.registrarMarcacion(
    1,
    'facial',
    latitud: -12.0464,
    longitud: -77.0428,
  );
}
