/// Base URL del API Nest (incluye sufijo `/api`).
/// En dispositivo físico usa la IP LAN de tu PC (no localhost).
/// Emulador Android → máquina host: `http://10.0.2.2:3000/api`
const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:3000/api',
);

const String kDeviceId = String.fromEnvironment(
  'DEVICE_ID',
  defaultValue: 'flutter-mobile-01',
);

const String kReplaySecret = String.fromEnvironment(
  'REPLAY_SECRET',
  defaultValue: 'offline-replay-secret-dev',
);

/// Umbral si no se pudo cargar config del servidor (cosine similarity 0–1).
/// Debe coincidir con `packages/shared-config/src/biometria-defaults.ts` (Dart no importa ese paquete).
const double kDefaultSimilarityThreshold = 0.55;

/// Cooldown local tras marcación OK si el servidor no devuelve segundos en 409.
const int kFallbackCooldownSeconds = 300;
