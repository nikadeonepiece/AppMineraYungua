# Control Asistencia — app Flutter (marcación facial)

Reconocimiento en el dispositivo con **Google ML Kit** (detección y seguimiento de rostros en tiempo real). Los **embeddings** se generan con el mismo flujo que la web (Nest → `face-service` InsightFace) y se comparan en el teléfono contra el catálogo (`GET /empleados/biometria/catalogo`). La **marcación** respeta el backend (`POST /asistencia/marcar`).

## Requisitos

- Flutter SDK estable (3.16+ recomendado)
- Android Studio / Xcode según plataforma
- Backend Nest en ejecución y `face-service` accesible desde la PC del servidor

## Primera instalación

En la carpeta del proyecto:

```bash
cd flutter_mobile
flutter pub get
flutter create . --org com.controlasistencia --project-name control_asistencia_mobile
```

El segundo comando genera las carpetas `android/` e `ios/` si aún no existen.

## URL del API

Por defecto el código usa `http://10.0.2.2:3000/api` (emulador Android → tu PC).

**Dispositivo físico:** usa la IP LAN de tu PC:

```bash
flutter run --dart-define=API_BASE=http://192.168.1.50:3000/api --dart-define=DEVICE_ID=tablet-recepcion-1
```

## CORS en el backend

Configura en `.env` del backend (IPs/orígenes separados por coma si hace falta):

```env
CORS_ORIGINS=http://localhost:5173
```

Para pruebas amplias puedes usar `CORS_ORIGINS=*` (no recomendado en producción).

## Colores de estado

- **Verde:** identidad reconocida y marcación aceptada por el servidor.
- **Amarillo:** bloqueo anti-duplicado (p. ej. mensaje 409) o ventana de espera local.
- **Rojo:** rostro sin coincidencia en el catálogo (por debajo del umbral de similitud).

## Notas

- Debe existir al menos un empleado activo con biometría registrada en BD.
- El usuario debe poder autenticarse (`POST /auth/login`) y llamar a catálogo, generar embedding y marcar asistencia según los roles/guards actuales del backend.
