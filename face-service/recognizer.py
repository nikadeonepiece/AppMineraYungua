import os
import time
import json
import re
from dataclasses import dataclass
from urllib import error as url_error
from urllib import request as url_request

import numpy as np


@dataclass
class Identity:
    person_id: str
    description: str
    embedding: np.ndarray


@dataclass
class RecognitionResult:
    label: str
    status: str  # recognized | cooldown | unknown
    score: float
    color: tuple[int, int, int]  # BGR para OpenCV


class BackendAttendanceClient:
    def __init__(
        self,
        api_base: str,
        auth_token: str | None,
        device_id: str,
        username: str | None = None,
        password: str | None = None,
    ):
        self.api_base = api_base.rstrip("/")
        self.auth_token = auth_token
        self.device_id = device_id
        self.username = username
        self.password = password
        self.refresh_token: str | None = None
        self.session_id: str | None = None

    def _json_post(self, endpoint: str, payload: dict, include_auth: bool = False):
        headers = {"Content-Type": "application/json"}
        if include_auth and self.auth_token:
            headers["Authorization"] = f"Bearer {self.auth_token}"

        req = url_request.Request(
            url=f"{self.api_base}{endpoint}",
            data=json.dumps(payload).encode("utf-8"),
            method="POST",
            headers=headers,
        )
        with url_request.urlopen(req, timeout=5) as response:
            raw = response.read().decode("utf-8")
            return json.loads(raw) if raw else {}

    def _try_login(self):
        if not self.username or not self.password:
            return False, "Faltan BACKEND_USERNAME/BACKEND_PASSWORD"
        try:
            parsed = self._json_post(
                endpoint="/auth/login",
                payload={"username": self.username, "password": self.password},
                include_auth=False,
            )
            self.auth_token = parsed.get("access_token") or parsed.get("accessToken")
            self.refresh_token = parsed.get("refresh_token") or parsed.get("refreshToken")
            self.session_id = parsed.get("sessionId")
            if not self.auth_token:
                return False, "Login sin access token"
            return True, "Login automatico exitoso"
        except url_error.HTTPError as exc:
            try:
                error_raw = exc.read().decode("utf-8")
                parsed = json.loads(error_raw) if error_raw else {}
                detail = parsed.get("message") or parsed.get("detail") or parsed
                return False, f"Login fallido: {detail}"
            except Exception:  # noqa: BLE001
                return False, f"Login fallido HTTP {exc.code}"
        except Exception as exc:  # noqa: BLE001
            return False, f"Login fallido: {exc}"

    def _try_refresh(self):
        if not self.refresh_token or not self.session_id:
            return False, "No hay refresh token/sessionId"
        try:
            parsed = self._json_post(
                endpoint="/auth/refresh",
                payload={"refreshToken": self.refresh_token, "sessionId": self.session_id},
                include_auth=False,
            )
            self.auth_token = parsed.get("access_token") or parsed.get("accessToken")
            self.refresh_token = parsed.get("refresh_token") or parsed.get("refreshToken")
            self.session_id = parsed.get("sessionId") or self.session_id
            if not self.auth_token:
                return False, "Refresh sin access token"
            return True, "Refresh exitoso"
        except Exception as exc:  # noqa: BLE001
            return False, f"Refresh fallido: {exc}"

    def ensure_auth_token(self):
        if self.auth_token:
            return True, None
        ok, message = self._try_login()
        if ok:
            return True, None
        return False, message

    def _mark_attendance_once(self, empleado_id: str):
        payload = {
            "empleado_id": empleado_id,
            "metodo": "facial",
            "dispositivo_id": self.device_id,
        }
        try:
            parsed = self._json_post(
                endpoint="/asistencia/marcar",
                payload=payload,
                include_auth=True,
            )
            message = str(parsed.get("mensaje", "Marcacion registrada correctamente"))
            return True, message
        except url_error.HTTPError as exc:
            try:
                error_raw = exc.read().decode("utf-8")
                parsed = json.loads(error_raw) if error_raw else {}
                detail = parsed.get("message") or parsed.get("detail") or parsed
                if isinstance(detail, list):
                    detail = " | ".join(str(v) for v in detail)
                return False, str(detail)
            except Exception:  # noqa: BLE001
                return False, f"Error HTTP {exc.code}"
        except Exception as exc:  # noqa: BLE001
            return False, f"Error de conexion backend: {exc}"

    def mark_attendance(self, empleado_id: str):
        ok, message = self.ensure_auth_token()
        if not ok:
            return False, message or "No se pudo autenticar"

        ok, message = self._mark_attendance_once(empleado_id)
        if ok:
            return True, message

        unauthorized = "401" in message or "no autenticado" in message.lower()
        if unauthorized:
            refreshed, _ = self._try_refresh()
            if not refreshed:
                relogin_ok, relogin_msg = self._try_login()
                if not relogin_ok:
                    return False, relogin_msg
            return self._mark_attendance_once(empleado_id)

        return False, message


class FaceRecognizer:
    def __init__(
        self,
        database_path: str = "known_faces.npz",
        cosine_threshold: float = 0.45,
        attendance_cooldown_seconds: int = 300,
    ):
        self.database_path = database_path
        self.cosine_threshold = cosine_threshold
        self.attendance_cooldown_seconds = attendance_cooldown_seconds
        self.identities = self._load_database(database_path)
        self.track_cache: dict[int, RecognitionResult] = {}
        self.last_marked_at: dict[str, float] = {}
        self.cooldown_until: dict[str, float] = {}
        self.backend_client = BackendAttendanceClient(
            api_base=os.getenv("BACKEND_API_BASE", "http://127.0.0.1:3000/api"),
            auth_token=os.getenv("BACKEND_AUTH_TOKEN"),
            device_id=os.getenv("DEVICE_ID", "camara-realtime-01"),
            username=os.getenv("BACKEND_USERNAME"),
            password=os.getenv("BACKEND_PASSWORD"),
        )

    @staticmethod
    def _cosine_distance(a: np.ndarray, b: np.ndarray) -> float:
        denom = np.linalg.norm(a) * np.linalg.norm(b)
        if denom == 0:
            return 1.0
        similarity = float(np.dot(a, b) / denom)
        return 1.0 - similarity

    def _load_database(self, path: str) -> list[Identity]:
        if not os.path.exists(path):
            return []

        data = np.load(path, allow_pickle=True)
        person_ids = data["person_ids"]
        descriptions = data["descriptions"]
        embeddings = data["embeddings"]

        identities: list[Identity] = []
        for idx in range(len(person_ids)):
            identities.append(
                Identity(
                    person_id=str(person_ids[idx]),
                    description=str(descriptions[idx]),
                    embedding=np.asarray(embeddings[idx], dtype=np.float32),
                )
            )
        return identities

    def _best_match(self, embedding: np.ndarray):
        if not self.identities:
            return None, 1.0

        best_identity = None
        best_distance = 1.0
        for identity in self.identities:
            distance = self._cosine_distance(identity.embedding, embedding)
            if distance < best_distance:
                best_distance = distance
                best_identity = identity
        return best_identity, best_distance

    def _is_in_cooldown(self, person_id: str, now_ts: float) -> bool:
        explicit_until = self.cooldown_until.get(person_id)
        if explicit_until is not None and now_ts < explicit_until:
            return True

        last_ts = self.last_marked_at.get(person_id)
        if last_ts is None:
            return False
        return (now_ts - last_ts) < self.attendance_cooldown_seconds

    def mark_attendance_if_allowed(self, person_id: str, now_ts: float) -> bool:
        if self._is_in_cooldown(person_id, now_ts):
            return False
        self.last_marked_at[person_id] = now_ts
        self.cooldown_until[person_id] = now_ts + self.attendance_cooldown_seconds
        return True

    @staticmethod
    def _extract_wait_seconds(message: str) -> int | None:
        match = re.search(r"Espere\s+(\d+)\s+segundos", message, flags=re.IGNORECASE)
        if not match:
            return None
        try:
            return int(match.group(1))
        except Exception:  # noqa: BLE001
            return None

    def recognize(self, track_id: int, embedding: list[float], refresh_cache: bool = True) -> RecognitionResult:
        if not refresh_cache and track_id in self.track_cache:
            return self.track_cache[track_id]

        emb = np.asarray(embedding, dtype=np.float32)
        identity, distance = self._best_match(emb)
        now_ts = time.time()

        if identity is None or distance > self.cosine_threshold:
            result = RecognitionResult(
                label="Desconocido",
                status="unknown",
                score=1.0 - float(distance),
                color=(0, 0, 255),  # Rojo
            )
        else:
            if self._is_in_cooldown(identity.person_id, now_ts):
                result = RecognitionResult(
                    label=f"{identity.description} (cooldown)",
                    status="cooldown",
                    score=1.0 - float(distance),
                    color=(0, 255, 255),  # Amarillo
                )
            else:
                ok, message = self.backend_client.mark_attendance(identity.person_id)
                if ok:
                    self.mark_attendance_if_allowed(identity.person_id, now_ts)
                    result = RecognitionResult(
                        label=f"{identity.description} | {message}",
                        status="recognized",
                        score=1.0 - float(distance),
                        color=(0, 255, 0),  # Verde
                    )
                else:
                    wait_seconds = self._extract_wait_seconds(message)
                    if wait_seconds is not None:
                        self.cooldown_until[identity.person_id] = now_ts + wait_seconds
                        result = RecognitionResult(
                            label=f"{identity.description} (cooldown servidor)",
                            status="cooldown",
                            score=1.0 - float(distance),
                            color=(0, 255, 255),  # Amarillo
                        )
                    else:
                        result = RecognitionResult(
                            label=f"{identity.description} (sin registro: {message})",
                            status="cooldown",
                            score=1.0 - float(distance),
                            color=(0, 255, 255),  # Amarillo
                        )

        self.track_cache[track_id] = result
        return result

    def evict_missing_tracks(self, alive_track_ids: set[int]) -> None:
        stale_ids = [track_id for track_id in self.track_cache if track_id not in alive_track_ids]
        for track_id in stale_ids:
            self.track_cache.pop(track_id, None)
