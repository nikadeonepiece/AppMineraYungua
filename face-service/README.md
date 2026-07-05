# Face Service (InsightFace)

Microservicio FastAPI para generar embeddings y comparar similitud facial.

## Dos modos (no los confundas)

| Modo | Comando | Para qué sirve |
|------|---------|----------------|
| **Solo API (sin ventana, sin cámara de la laptop)** | `uvicorn app:app --host 0.0.0.0 --port 8001` | Nest y tu app móvil usan el backend; el **PC** llama a este servicio al generar embeddings. Es lo que debes usar si reconoces **desde el celular**. |
| **Escritorio con cámara y ventana OpenCV** | `python main.py` | Prueba local con webcam; abre una ventana. **No** es necesario para el celular. |

Tu celular **no** se conecta directamente al puerto 8001 por defecto: envía la imagen al **API Nest** (`/empleados/biometria/generate-embedding`), y Nest habla con `FACE_SERVICE_URL` en tu PC.

## Ejecutar solo el servicio HTTP (recomendado para móvil / producción local)

```bash
cd face-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8001
```

Comprueba: `http://127.0.0.1:8001/health` debe responder `{"ok":true}`.

## Endpoints

- `POST /generate-embedding`
  - input: `{ "imageBase64": "..." }`
  - output: `{ "embedding": [float, ...] }`

- `POST /compare`
  - input: `{ "embedding1": [...], "embedding2": [...] }`
  - output: `{ "score": 0.91 }`

## Configuracion

- `FACE_CUDA=1` para intentar GPU.
- Backend Nest consume por `FACE_SERVICE_URL` (default `http://127.0.0.1:8001`).

## Pipeline en tiempo real (refactor de captura)

Se agrego un pipeline modular para reemplazar la captura por intervalos:

- `video_stream.py`: captura continua con `cv2.VideoCapture`.
- `face_detector.py`: deteccion multi-rostro (InsightFace/RetinaFace).
- `tracker.py`: tracking estilo SORT con IDs persistentes.
- `recognizer.py`: reconocimiento con embeddings + cache por `track_id` + cooldown de asistencia (5 min).
- `main.py`: orquestacion en tiempo real y visualizacion (`cv2.imshow`).

### Ejecutar streaming local

```bash
cd face-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

El script carga variables desde `.env` automaticamente.

Presiona `q` para salir.

### Base de datos de embeddings esperada

`main.py` usa por defecto `known_faces.npz` en la carpeta `face-service` con:

- `person_ids`: array de IDs unicos
- `descriptions`: array con nombre/descripcion para mostrar en pantalla
- `embeddings`: array de embeddings normalizados

## Integracion con regla de negocio del servidor

`recognizer.py` ahora llama al backend en cada reconocimiento valido:

- `POST {BACKEND_API_BASE}/asistencia/marcar`
- Body: `{ empleado_id, metodo: "facial", dispositivo_id }`
- Header: `Authorization: Bearer <BACKEND_AUTH_TOKEN>`

Autenticacion soportada:

- **Automatica (recomendada):** `BACKEND_USERNAME` + `BACKEND_PASSWORD`  
  El script hace login en `/auth/login`, guarda `access_token`, `refresh_token`, `sessionId` y refresca en `/auth/refresh` si expira.
- **Manual (fallback):** `BACKEND_AUTH_TOKEN`  
  Si defines token manual, lo usa directamente.

`.env` de ejemplo:

```env
BACKEND_API_BASE=http://127.0.0.1:3000/api
BACKEND_USERNAME=admin
BACKEND_PASSWORD=123456
DEVICE_ID=camara-puerta-1
```

Comportamiento en UI:

- Verde: backend acepto la marcacion.
- Amarillo: backend bloqueo por ventana anti-duplicado (5 min o el valor del servidor).
- Rojo: rostro desconocido.

