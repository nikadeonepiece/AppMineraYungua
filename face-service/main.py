import logging
import time

import cv2
from dotenv import load_dotenv

from face_detector import FaceDetector
from recognizer import FaceRecognizer
from tracker import SortLikeTracker
from video_stream import VideoStream

load_dotenv()


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)


def draw_face(frame, bbox, label: str, color: tuple[int, int, int]) -> None:
    x1, y1, x2, y2 = bbox
    cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
    cv2.putText(
        frame,
        label,
        (x1, max(20, y1 - 10)),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        color,
        2,
        cv2.LINE_AA,
    )


def run() -> None:
    stream = VideoStream(camera_index=0, width=1280, height=720)
    detector = FaceDetector(
        det_size=(640, 640),
        min_score=0.50,
        downscale=0.75,
    )
    tracker = SortLikeTracker(iou_threshold=0.30, max_missed=10, min_hits=1)
    recognizer = FaceRecognizer(
        database_path="known_faces.npz",
        cosine_threshold=0.45,
        attendance_cooldown_seconds=300,
    )

    detection_interval = 5
    frame_index = 0
    latest_detections = []
    last_time = time.time()

    stream.start()
    logging.info("Streaming facial iniciado. Presiona 'q' para salir.")

    try:
        while True:
            frame = stream.read()
            if frame is None:
                logging.warning("No se pudo leer frame de camara")
                break

            frame_index += 1
            do_detect = (frame_index % detection_interval) == 0

            if do_detect:
                latest_detections = detector.detect(frame)

            if do_detect:
                detection_boxes = [d.bbox for d in latest_detections]
                tracks = tracker.update(detection_boxes)
            else:
                tracks = tracker.active_tracks()
            alive_ids = {t.track_id for t in tracks}
            recognizer.evict_missing_tracks(alive_ids)

            for track in tracks:
                result = None
                if track.last_detection_index is not None and track.last_detection_index < len(latest_detections):
                    det = latest_detections[track.last_detection_index]
                    result = recognizer.recognize(
                        track_id=track.track_id,
                        embedding=det.embedding,
                        refresh_cache=do_detect,
                    )
                elif track.track_id in recognizer.track_cache:
                    result = recognizer.track_cache[track.track_id]

                if result is None:
                    continue

                label = f"ID {track.track_id} | {result.label} | {result.score:.2f}"
                draw_face(frame, track.bbox, label, result.color)

            now = time.time()
            fps = 1.0 / max(1e-6, now - last_time)
            last_time = now
            cv2.putText(
                frame,
                f"FPS: {fps:.1f}",
                (20, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.8,
                (255, 255, 255),
                2,
                cv2.LINE_AA,
            )

            cv2.imshow("Reconocimiento Facial - Tiempo Real", frame)
            if cv2.waitKey(1) & 0xFF == ord("q"):
                break
    finally:
        stream.stop()
        cv2.destroyAllWindows()
        logging.info("Streaming finalizado.")


if __name__ == "__main__":
    run()
