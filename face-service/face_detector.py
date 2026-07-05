import os
from dataclasses import dataclass

import cv2
from insightface.app import FaceAnalysis


@dataclass
class Detection:
    bbox: tuple[int, int, int, int]
    score: float
    embedding: list[float]


class FaceDetector:
    """
    Detector de rostros basado en InsightFace (RetinaFace en buffalo_l).
    """

    def __init__(
        self,
        det_size: tuple[int, int] = (640, 640),
        min_score: float = 0.50,
        downscale: float = 1.0,
    ):
        self.min_score = min_score
        self.downscale = downscale
        self.ctx_id = self._resolve_ctx_id()
        self.app = FaceAnalysis(name="buffalo_l")
        self.app.prepare(ctx_id=self.ctx_id, det_size=det_size)

    @staticmethod
    def _resolve_ctx_id() -> int:
        """
        - 0: GPU/CUDA (si onnxruntime-gpu esta instalado y usable).
        - -1: CPU fallback.
        """
        use_cuda_env = os.getenv("FACE_CUDA", "").strip()
        if use_cuda_env in {"1", "true", "TRUE", "True"}:
            return 0
        return -1

    def detect(self, frame_bgr):
        original_h, original_w = frame_bgr.shape[:2]

        if 0.1 < self.downscale < 1.0:
            small = cv2.resize(
                frame_bgr,
                (int(original_w * self.downscale), int(original_h * self.downscale)),
                interpolation=cv2.INTER_LINEAR,
            )
            faces = self.app.get(small)
            scale = 1.0 / self.downscale
        else:
            faces = self.app.get(frame_bgr)
            scale = 1.0

        detections: list[Detection] = []
        for face in faces:
            score = float(getattr(face, "det_score", 1.0))
            if score < self.min_score:
                continue

            x1, y1, x2, y2 = face.bbox.astype(float).tolist()
            x1 = int(max(0, x1 * scale))
            y1 = int(max(0, y1 * scale))
            x2 = int(min(original_w - 1, x2 * scale))
            y2 = int(min(original_h - 1, y2 * scale))

            if x2 <= x1 or y2 <= y1:
                continue

            embedding = face.normed_embedding.astype("float32").tolist()
            detections.append(
                Detection(
                    bbox=(x1, y1, x2, y2),
                    score=score,
                    embedding=embedding,
                )
            )

        return detections
