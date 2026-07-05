import cv2


class VideoStream:
    """Administra captura continua de video desde webcam."""

    def __init__(self, camera_index: int = 0, width: int = 1280, height: int = 720):
        self.camera_index = camera_index
        self.width = width
        self.height = height
        self.cap = None

    def start(self) -> None:
        self.cap = cv2.VideoCapture(self.camera_index)
        if not self.cap.isOpened():
            raise RuntimeError(f"No se pudo abrir la camara {self.camera_index}")
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, self.width)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, self.height)

    def read(self):
        if self.cap is None:
            raise RuntimeError("VideoStream no ha sido iniciado")
        ok, frame = self.cap.read()
        if not ok:
            return None
        return frame

    def stop(self) -> None:
        if self.cap is not None:
            self.cap.release()
            self.cap = None
