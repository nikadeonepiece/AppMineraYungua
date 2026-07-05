import base64
import os
from typing import List

import cv2
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from insightface.app import FaceAnalysis


class GenerateEmbeddingRequest(BaseModel):
    imageBase64: str = Field(min_length=50)


class CompareRequest(BaseModel):
    embedding1: List[float] = Field(min_length=16)
    embedding2: List[float] = Field(min_length=16)


app = FastAPI(title="Face Embedding Service", version="1.0.0")

face_app = FaceAnalysis(name="buffalo_l")
face_app.prepare(ctx_id=0 if os.getenv("FACE_CUDA", "0") == "1" else -1)

# Umbrales ligeramente mas flexibles para camaras moviles en condiciones no ideales.
# Se pueden sobreescribir por variables de entorno sin tocar codigo.
MIN_DET_SCORE = float(os.getenv("FACE_MIN_DET_SCORE", "0.50"))
MIN_FACE_AREA_RATIO = float(os.getenv("FACE_MIN_AREA_RATIO", "0.04"))

# Registro / alta: mas estricto que marcacion puntual (generate-embedding).
ENROLL_MIN_DET_SCORE = float(os.getenv("FACE_ENROLL_MIN_DET_SCORE", "0.54"))
ENROLL_MIN_AREA_RATIO = float(os.getenv("FACE_ENROLL_MIN_AREA_RATIO", "0.055"))
ENROLL_MULTI_MIN_DET = float(os.getenv("FACE_ENROLL_MULTI_MIN_DET", "0.40"))
ENROLL_MULTI_MIN_AREA_RATIO = float(os.getenv("FACE_ENROLL_MULTI_MIN_AREA_RATIO", "0.022"))
ENROLL_MAX_CENTER_OFFSET = float(os.getenv("FACE_ENROLL_MAX_CENTER_OFFSET", "0.20"))
ENROLL_MIN_LAPLACIAN_VAR = float(os.getenv("FACE_ENROLL_MIN_LAPLACIAN_VAR", "28.0"))
ENROLL_MIN_DET_LIVENESS = float(os.getenv("FACE_ENROLL_MIN_DET_LIVENESS", "0.56"))
ENROLL_MIN_TEXTURE_STD = float(os.getenv("FACE_ENROLL_MIN_TEXTURE_STD", "5.5"))


def _decode_image(image_base64: str) -> np.ndarray:
    try:
        raw = base64.b64decode(image_base64)
        array = np.frombuffer(raw, dtype=np.uint8)
        image = cv2.imdecode(array, cv2.IMREAD_COLOR)
        if image is None:
            raise ValueError("Imagen invalida")
        return image
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=400, detail="No se pudo decodificar la imagen base64") from exc


def _cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    denom = np.linalg.norm(a) * np.linalg.norm(b)
    if denom == 0:
        return 0.0
    return float(np.dot(a, b) / denom)


def _face_metrics(face, image: np.ndarray) -> tuple[float, float]:
    h, w = image.shape[:2]
    image_area = max(1.0, float(h * w))
    x1, y1, x2, y2 = face.bbox.astype(np.float32).tolist()
    face_area = max(1.0, (x2 - x1) * (y2 - y1))
    area_ratio = float(face_area / image_area)
    det_score = float(getattr(face, "det_score", 1.0))
    return det_score, area_ratio


def _faces_meeting_thresholds(
    faces: list,
    image: np.ndarray,
    min_det: float,
    min_area_ratio: float,
) -> list[tuple[object, float, float]]:
    """Lista de (face, det_score, area_ratio) que cumplen umbrales."""
    out: list[tuple[object, float, float]] = []
    for face in faces:
        det_score, area_ratio = _face_metrics(face, image)
        if det_score >= min_det and area_ratio >= min_area_ratio:
            out.append((face, det_score, area_ratio))
    return out


def _pick_valid_face(faces: list, image: np.ndarray):
    if not faces:
        return None

    valid_faces = _faces_meeting_thresholds(faces, image, MIN_DET_SCORE, MIN_FACE_AREA_RATIO)
    if not valid_faces:
        return None

    # De los rostros válidos, tomamos el de mayor área.
    return max(valid_faces, key=lambda item: item[2])[0]


def _yaw_norm_from_kps(face) -> float:
    """Proxy de yaw a partir de landmarks; 0 si no hay kps."""
    kps = getattr(face, "kps", None)
    if kps is None:
        return 0.0
    arr = np.asarray(kps, dtype=np.float32)
    if arr.shape[0] < 3:
        return 0.0
    le, re, nose = arr[0], arr[1], arr[2]
    eye_mid = (le + re) * 0.5
    inter_eye = float(np.linalg.norm(re - le)) + 1e-6
    return float((nose[0] - eye_mid[0]) / inter_eye)


def _laplacian_variance_bgr(image_bgr: np.ndarray, face) -> float:
    x1, y1, x2, y2 = face.bbox.astype(np.int32).tolist()
    h, w = image_bgr.shape[:2]
    pad_x = max(1, int((x2 - x1) * 0.08))
    pad_y = max(1, int((y2 - y1) * 0.08))
    xa, ya = max(0, x1 - pad_x), max(0, y1 - pad_y)
    xb, yb = min(w, x2 + pad_x), min(h, y2 + pad_y)
    if xb <= xa or yb <= ya:
        return 0.0
    crop = image_bgr[ya:yb, xa:xb]
    gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def _texture_std_bgr(image_bgr: np.ndarray, face) -> float:
    """Textura local (Sobel); ayuda a descartar planos uniformes o pantallas muy lisas."""
    x1, y1, x2, y2 = face.bbox.astype(np.int32).tolist()
    h, w = image_bgr.shape[:2]
    pad_x = max(1, int((x2 - x1) * 0.06))
    pad_y = max(1, int((y2 - y1) * 0.06))
    xa, ya = max(0, x1 - pad_x), max(0, y1 - pad_y)
    xb, yb = min(w, x2 + pad_x), min(h, y2 + pad_y)
    if xb <= xa or yb <= ya:
        return 0.0
    gray = cv2.cvtColor(image_bgr[ya:yb, xa:xb], cv2.COLOR_BGR2GRAY)
    gx = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
    gy = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
    mag = np.sqrt(gx * gx + gy * gy)
    return float(np.std(mag))


def _center_offset_norm(face, image: np.ndarray) -> tuple[float, float]:
    h, w = image.shape[:2]
    x1, y1, x2, y2 = face.bbox.astype(np.float32).tolist()
    cx = (x1 + x2) * 0.5
    cy = (y1 + y2) * 0.5
    norm = float(max(min(w, h), 1))
    return abs(cx - w * 0.5) / norm, abs(cy - h * 0.5) / norm


def _glare_risk_in_eye_region(image_bgr: np.ndarray, face) -> float:
    """
    Heuristica 0..1: brillo alto en parches oculares (reflejo en lentes).
    No sustituye un clasificador de gafas; solo avisa en UI/registro.
    """
    kps = getattr(face, "kps", None)
    if kps is None:
        return 0.0
    arr = np.asarray(kps, dtype=np.float32)
    if arr.shape[0] < 2:
        return 0.0
    le, re = arr[0], arr[1]
    inter_eye = float(np.linalg.norm(re - le)) + 1e-6
    patch = max(6, int(inter_eye * 0.22))
    h, w = image_bgr.shape[:2]
    risks: list[float] = []
    for eye in (le, re):
        cx, cy = int(eye[0]), int(eye[1])
        xa, ya = max(0, cx - patch), max(0, cy - patch)
        xb, yb = min(w, cx + patch), min(h, cy + patch)
        if xb <= xa or yb <= ya:
            continue
        roi = image_bgr[ya:yb, xa:xb]
        gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
        bright = float(np.mean(gray >= 220))
        sat = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)[:, :, 1]
        spec = float(np.mean((gray >= 200) & (sat.astype(np.float32) < 55.0)))
        risks.append(min(1.0, bright * 0.55 + spec * 0.75))
    if not risks:
        return 0.0
    return float(max(risks))


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/generate-embedding")
def generate_embedding(payload: GenerateEmbeddingRequest):
    image = _decode_image(payload.imageBase64)
    faces = face_app.get(image)
    face = _pick_valid_face(faces, image)
    if face is None:
        raise HTTPException(
            status_code=422,
            detail="No se detecto rostro valido (acercar rostro y mejorar enfoque/iluminacion)",
        )
    vector = face.normed_embedding.astype(np.float32)
    return {"embedding": vector.tolist()}


@app.post("/detect-face")
def detect_face(payload: GenerateEmbeddingRequest):
    image = _decode_image(payload.imageBase64)
    faces = face_app.get(image)
    valid = _faces_meeting_thresholds(faces, image, MIN_DET_SCORE, MIN_FACE_AREA_RATIO)
    count = len(valid)
    return {"hasFace": count > 0, "count": count}


@app.post("/enrollment-capture")
def enrollment_capture(payload: GenerateEmbeddingRequest):
    """
    Una sola pasada InsightFace para alta: embedding solo si pasa calidad,
    centrado, una cara dominante y heuristica basica de textura (no es liveness fuerte).
    """
    image = _decode_image(payload.imageBase64)
    faces = face_app.get(image)
    if not faces:
        raise HTTPException(
            status_code=422,
            detail="No se detecto ningun rostro. Mejore iluminacion y acerque el rostro.",
        )

    multi = _faces_meeting_thresholds(
        faces,
        image,
        ENROLL_MULTI_MIN_DET,
        ENROLL_MULTI_MIN_AREA_RATIO,
    )
    if len(multi) > 1:
        raise HTTPException(
            status_code=422,
            detail="Se detecto mas de un rostro. Asegure una sola persona en encuadre.",
        )

    strict = _faces_meeting_thresholds(
        faces,
        image,
        ENROLL_MIN_DET_SCORE,
        ENROLL_MIN_AREA_RATIO,
    )
    if not strict:
        raise HTTPException(
            status_code=422,
            detail="Rostro demasiado pequeño o poco nitido. Acerque mas el rostro al encuadre.",
        )

    face, det_score, area_ratio = max(strict, key=lambda item: item[2])

    if det_score < ENROLL_MIN_DET_LIVENESS:
        raise HTTPException(
            status_code=422,
            detail="Baja confianza de deteccion (posible desenfoque o pantalla). Use luz natural y mire a camara.",
        )

    ox, oy = _center_offset_norm(face, image)
    if max(ox, oy) > ENROLL_MAX_CENTER_OFFSET:
        raise HTTPException(
            status_code=422,
            detail="Centre el rostro en el marco (no demasiado a los lados ni arriba/abajo).",
        )

    lap_var = _laplacian_variance_bgr(image, face)
    if lap_var < ENROLL_MIN_LAPLACIAN_VAR:
        raise HTTPException(
            status_code=422,
            detail="Imagen demasiado borrosa. Espere enfoque estable o limpie la lente.",
        )

    tex = _texture_std_bgr(image, face)
    if tex < ENROLL_MIN_TEXTURE_STD:
        raise HTTPException(
            status_code=422,
            detail="Poca textura facial detectada (posible foto de pantalla o iluminacion plana).",
        )

    vector = face.normed_embedding.astype(np.float32)
    yaw_norm = _yaw_norm_from_kps(face)
    glare_risk = _glare_risk_in_eye_region(image, face)
    return {
        "embedding": vector.tolist(),
        "metrics": {
            "detScore": det_score,
            "faceAreaRatio": area_ratio,
            "blurVariance": lap_var,
            "textureStd": tex,
            "yawNorm": yaw_norm,
            "centerOffsetX": ox,
            "centerOffsetY": oy,
            "glareRisk": glare_risk,
            "glassesLikely": glare_risk >= 0.38,
        },
    }


@app.post("/compare")
def compare_embeddings(payload: CompareRequest):
    a = np.array(payload.embedding1, dtype=np.float32)
    b = np.array(payload.embedding2, dtype=np.float32)
    if a.shape != b.shape:
        raise HTTPException(status_code=400, detail="Los embeddings deben tener la misma dimension")

    score = _cosine_similarity(a, b)
    return {"score": score}

